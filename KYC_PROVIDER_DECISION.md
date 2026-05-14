# KYC Provider Decision Notes

## Current recommendation

MVP icin provider-agnostic backend kuruldu. Ilk gercek entegrasyon icin iki pratik aday:

1. Veriff
   - KYC/IDV odakli.
   - Session olusturunca verification URL doner.
   - Decision webhook ile approved/declined gibi kararlar backend'e gelir.
   - Hosted/SDK akisa uygun.

2. Sumsub
   - Applicant + access token / verification flow mantigi guclu.
   - Webhook ile applicantReviewed sonucu gelir.
   - KYC operasyonlari icin esnek.

Stripe Identity daha hizli baslatilabilir ama PatiParent icin pet marketplace KYC baglaminda Veriff/Sumsub daha dogal adaylar gibi duruyor. Stripe Identity alternatif olarak kalmali.

## Implemented integration

Functions eklendi:

- `createVerificationSession` callable function
- `kycWebhook` HTTP function
- Veriff hosted verification session adapter
- Sumsub applicant + SDK access token adapter

UI eklendi:

- `IdentityVerificationPage` once Veriff provider ile callable function'i cagirir.
- Function deploy edilmemisse guvenli local pending request fallback'e duser.
- Gercek mavi tik sadece backend/provider webhook ile `users/{uid}` dokumanina yazilacak.

## Deployment blocker

Firebase Functions deploy denendi ama proje Blaze plana gecmeden olmuyor.

Firebase CLI hatasi:

```text
Your project patimatch-app-2026-berkay must be on the Blaze (pay-as-you-go) plan...
Required API artifactregistry.googleapis.com can't be enabled until the upgrade is complete.
```

## To activate real KYC

1. Firebase project'i Blaze plana gecir.
2. Veriff dashboard'da API key olustur.
3. Secret/config ekle:
   - `VERIFF_API_KEY`
   - `KYC_WEBHOOK_SECRET`
   - opsiyonel `APP_BASE_URL=https://patiparent.com`
   - Sumsub kullanilacaksa `SUMSUB_APP_TOKEN`, `SUMSUB_SECRET_KEY`, `SUMSUB_LEVEL_NAME`
4. Adapter zaten `functions/index.js` icinde baglandi. Uygulama ilk olarak Veriff'i cagiriyor.
5. `firebase deploy --only functions --project prod` calistir.
6. Provider dashboard'da webhook URL tanimla:
   - `https://europe-west1-patimatch-app-2026-berkay.cloudfunctions.net/kycWebhook?provider=<provider>`
7. Test kullanicisiyle verified/rejected/needs_review akisini dene.

## Firebase secret commands

Blaze plan sonrasi:

```powershell
firebase functions:secrets:set VERIFF_API_KEY --project prod
firebase functions:secrets:set KYC_WEBHOOK_SECRET --project prod
firebase deploy --only functions --project prod
```

Sumsub denenirse:

```powershell
firebase functions:secrets:set SUMSUB_APP_TOKEN --project prod
firebase functions:secrets:set SUMSUB_SECRET_KEY --project prod
firebase functions:config:set sumsub.level_name=\"basic-kyc-level\" --project prod
firebase deploy --only functions --project prod
```

## Security rule

Firestore rules kullanicinin kendi `blueBadge`, `verificationStatus`, `verificationLevel`, `trustBadges` alanlarini yazmasini engelliyor. Bu alanlar sadece Admin SDK kullanan backend tarafindan guncellenebilir.
