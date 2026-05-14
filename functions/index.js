const { onCall, HttpsError, onRequest } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();

const db = admin.firestore();

const SUPPORTED_PROVIDERS = new Set(['veriff', 'sumsub', 'persona', 'onfido', 'stripe_identity', 'demo']);
const REGION = 'europe-west1';
const APP_BASE_URL = process.env.APP_BASE_URL || 'https://patiparent.com';
const VERIFF_API_KEY = defineSecret('VERIFF_API_KEY');
const KYC_WEBHOOK_SECRET = defineSecret('KYC_WEBHOOK_SECRET');

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError('unauthenticated', 'Kimlik dogrulama baslatmak icin giris yapmalisin.');
  }
  return request.auth.uid;
}

function normalizeProvider(value) {
  const provider = String(value || process.env.DEFAULT_KYC_PROVIDER || 'demo').toLowerCase();
  if (!SUPPORTED_PROVIDERS.has(provider)) {
    throw new HttpsError('invalid-argument', `Desteklenmeyen KYC saglayici: ${provider}`);
  }
  return provider;
}

async function createDemoSession({ userId, provider }) {
  const sessionRef = db.collection('verificationSessions').doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const verificationUrl = `https://patiparent.com/verification-demo?session=${sessionRef.id}`;

  await sessionRef.set({
    userId,
    provider,
    status: 'pending',
    providerReference: sessionRef.id,
    verificationUrl,
    createdAt: now,
    updatedAt: now,
    decisionReason: 'Demo KYC session. Replace provider adapter with real hosted verification URL.',
  });

  await db.collection('users').doc(userId).set({
    verificationStatus: 'pending',
    verificationLevel: 'phone_email',
    verificationProvider: provider,
    verificationSessionId: sessionRef.id,
    blueBadge: false,
    updatedAt: now,
  }, { merge: true });

  return {
    sessionId: sessionRef.id,
    provider,
    status: 'pending',
    verificationUrl,
  };
}

async function getSafeUserProfile(userId) {
  const authUser = await admin.auth().getUser(userId);
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data() || {};
  return {
    email: authUser.email || userData.email || undefined,
    phone: authUser.phoneNumber || userData.phone || undefined,
    displayName: authUser.displayName || userData.displayName || undefined,
  };
}

async function createVeriffSession({ userId }) {
  const apiKey = VERIFF_API_KEY.value() || process.env.VERIFF_API_KEY;
  if (!apiKey) {
    throw new HttpsError(
      'failed-precondition',
      'Veriff API key tanimli degil. Firebase Functions secret/config eklenmeli.',
    );
  }

  const profile = await getSafeUserProfile(userId);
  const body = {
    verification: {
      callback: `${APP_BASE_URL}/#/settings`,
      vendorData: userId,
      person: {
        givenName: profile.displayName || 'PatiParent',
      },
    },
  };

  const response = await fetch('https://stationapi.veriff.com/v1/sessions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-AUTH-CLIENT': apiKey,
    },
    body: JSON.stringify(body),
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    logger.error('Veriff session creation failed', {
      status: response.status,
      payload,
    });
    throw new HttpsError(
      'internal',
      'Veriff dogrulama oturumu olusturulamadi.',
    );
  }

  const verification = payload.verification || {};
  const providerReference = verification.id || verification.sessionToken;
  const verificationUrl = verification.url;
  if (!providerReference || !verificationUrl) {
    logger.error('Veriff response missing session fields', { payload });
    throw new HttpsError('internal', 'Veriff dogrulama linki donmedi.');
  }

  return createProviderSessionRecord({
    userId,
    provider: 'veriff',
    providerReference,
    verificationUrl,
    providerPayload: {
      sessionId: verification.id || null,
      status: verification.status || 'created',
    },
  });
}

function signSumsubRequest({ method, path, body }) {
  const secret = process.env.SUMSUB_SECRET_KEY;
  if (!secret) {
    throw new HttpsError(
      'failed-precondition',
      'Sumsub secret key tanimli degil. Firebase Functions secret/config eklenmeli.',
    );
  }
  const ts = Math.floor(Date.now() / 1000).toString();
  const bodyText = body ? JSON.stringify(body) : '';
  const signature = crypto
    .createHmac('sha256', secret)
    .update(ts + method.toUpperCase() + path + bodyText)
    .digest('hex');
  return { ts, signature, bodyText };
}

async function sumsubFetch({ method, path, body }) {
  const appToken = process.env.SUMSUB_APP_TOKEN;
  if (!appToken) {
    throw new HttpsError(
      'failed-precondition',
      'Sumsub app token tanimli degil. Firebase Functions secret/config eklenmeli.',
    );
  }
  const signed = signSumsubRequest({ method, path, body });
  const response = await fetch(`https://api.sumsub.com${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'X-App-Token': appToken,
      'X-App-Access-Ts': signed.ts,
      'X-App-Access-Sig': signed.signature,
    },
    body: body ? signed.bodyText : undefined,
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    logger.error('Sumsub API request failed', {
      method,
      path,
      status: response.status,
      payload,
    });
    throw new HttpsError('internal', 'Sumsub dogrulama oturumu olusturulamadi.');
  }
  return payload;
}

async function createSumsubSession({ userId }) {
  const levelName = process.env.SUMSUB_LEVEL_NAME || 'basic-kyc-level';
  const profile = await getSafeUserProfile(userId);
  const applicant = await sumsubFetch({
    method: 'POST',
    path: `/resources/applicants?levelName=${encodeURIComponent(levelName)}`,
    body: {
      externalUserId: userId,
      email: profile.email,
      phone: profile.phone,
      lang: 'tr',
      type: 'individual',
    },
  });
  const tokenPath =
    `/resources/accessTokens/sdk?userId=${encodeURIComponent(userId)}` +
    `&levelName=${encodeURIComponent(levelName)}&ttlInSecs=1200`;
  const accessToken = await sumsubFetch({
    method: 'POST',
    path: tokenPath,
  });

  return createProviderSessionRecord({
    userId,
    provider: 'sumsub',
    providerReference: applicant.id || userId,
    verificationUrl: '',
    sdkToken: accessToken.token || '',
    providerPayload: {
      applicantId: applicant.id || null,
      inspectionId: applicant.inspectionId || null,
    },
  });
}

async function createProviderSessionRecord({
  userId,
  provider,
  providerReference,
  verificationUrl,
  sdkToken,
  providerPayload,
}) {
  const sessionRef = db.collection('verificationSessions').doc();
  const now = admin.firestore.FieldValue.serverTimestamp();

  await sessionRef.set({
    userId,
    provider,
    status: 'pending',
    providerReference,
    verificationUrl: verificationUrl || null,
    hasSdkToken: Boolean(sdkToken),
    providerPayload: providerPayload || null,
    createdAt: now,
    updatedAt: now,
    decisionReason: null,
  });

  await db.collection('users').doc(userId).set({
    verificationStatus: 'pending',
    verificationLevel: 'phone_email',
    verificationProvider: provider,
    verificationSessionId: sessionRef.id,
    blueBadge: false,
    updatedAt: now,
  }, { merge: true });

  return {
    sessionId: sessionRef.id,
    provider,
    status: 'pending',
    verificationUrl: verificationUrl || '',
    sdkToken: sdkToken || '',
  };
}

exports.createVerificationSession = onCall({
  region: REGION,
  secrets: [VERIFF_API_KEY],
}, async (request) => {
  const userId = requireAuth(request);
  const provider = normalizeProvider(request.data && request.data.provider);

  if (provider === 'veriff') {
    return createVeriffSession({ userId });
  }
  if (provider === 'sumsub') {
    return createSumsubSession({ userId });
  }
  if (provider !== 'demo') {
    throw new HttpsError(
      'failed-precondition',
      `${provider} adapter henuz aktif degil. Veriff veya Sumsub kullan.`,
    );
  }
  return createDemoSession({ userId, provider });
});

function verifyWebhookSignature(provider, req) {
  // Placeholder: each KYC provider has a different signature scheme.
  // Keep this strict before production. Never trust unsigned webhooks.
  if (provider === 'demo') return true;
  const configuredSecret =
    KYC_WEBHOOK_SECRET.value() || process.env.KYC_WEBHOOK_SECRET;
  if (!configuredSecret) return false;
  const signature = req.get('x-patiparent-signature') || '';
  const digest = crypto
    .createHmac('sha256', configuredSecret)
    .update(req.rawBody || Buffer.from(JSON.stringify(req.body || {})))
    .digest('hex');
  const signatureBuffer = Buffer.from(signature);
  const digestBuffer = Buffer.from(digest);
  if (signatureBuffer.length !== digestBuffer.length) return false;
  return crypto.timingSafeEqual(signatureBuffer, digestBuffer);
}

function mapProviderStatus(payload) {
  const rawStatus = String(payload.status || payload.reviewAnswer || payload.decision || '').toLowerCase();
  if (['approved', 'verified', 'green', 'passed'].includes(rawStatus)) return 'verified';
  if (['declined', 'rejected', 'red', 'failed'].includes(rawStatus)) return 'rejected';
  if (['review', 'needs_review', 'resubmission_requested'].includes(rawStatus)) return 'needs_review';
  return 'pending';
}

exports.kycWebhook = onRequest({
  region: REGION,
  secrets: [KYC_WEBHOOK_SECRET],
}, async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }

  const provider = normalizeProvider(req.query.provider || (req.body && req.body.provider) || 'demo');
  if (!verifyWebhookSignature(provider, req)) {
    logger.warn('Rejected unsigned KYC webhook', { provider });
    res.status(401).send('Invalid signature');
    return;
  }

  const payload = req.body || {};
  const providerReference = String(payload.providerReference || payload.sessionId || payload.id || '');
  if (!providerReference) {
    res.status(400).send('Missing provider reference');
    return;
  }

  const sessions = await db
    .collection('verificationSessions')
    .where('providerReference', '==', providerReference)
    .limit(1)
    .get();

  if (sessions.empty) {
    res.status(404).send('Session not found');
    return;
  }

  const sessionDoc = sessions.docs[0];
  const session = sessionDoc.data();
  const status = mapProviderStatus(payload);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await sessionDoc.ref.set({
    status,
    updatedAt: now,
    decisionReason: payload.reason || payload.reviewRejectType || null,
  }, { merge: true });

  await db.collection('users').doc(session.userId).set({
    verificationStatus: status,
    verificationLevel: status === 'verified' ? 'identity' : 'phone_email',
    verificationProvider: provider,
    verificationSessionId: sessionDoc.id,
    verifiedAt: status === 'verified' ? now : null,
    blueBadge: status === 'verified',
    trustBadges: status === 'verified'
      ? ['Kimlik dogrulandi', 'Telefon dogrulandi']
      : ['Telefon dogrulandi'],
    updatedAt: now,
  }, { merge: true });

  res.json({ ok: true, status });
});


