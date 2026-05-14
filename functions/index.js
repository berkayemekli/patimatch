const { onCall, HttpsError, onRequest } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();

const db = admin.firestore();

const SUPPORTED_PROVIDERS = new Set(['veriff', 'sumsub', 'persona', 'onfido', 'stripe_identity', 'demo']);

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

exports.createVerificationSession = onCall({ region: 'europe-west1' }, async (request) => {
  const userId = requireAuth(request);
  const provider = normalizeProvider(request.data && request.data.provider);

  // TODO: Replace demo with selected provider adapter.
  // Veriff: POST /v1/sessions and return verification.url.
  // Sumsub: create applicant + access token / verification link.
  // Persona: create inquiry and return hosted inquiry URL.
  // Stripe Identity: create VerificationSession and return client_secret/url strategy.
  return createDemoSession({ userId, provider });
});

function verifyWebhookSignature(provider, req) {
  // Placeholder: each KYC provider has a different signature scheme.
  // Keep this strict before production. Never trust unsigned webhooks.
  if (provider === 'demo') return true;
  const configuredSecret = process.env.KYC_WEBHOOK_SECRET;
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

exports.kycWebhook = onRequest({ region: 'europe-west1' }, async (req, res) => {
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
