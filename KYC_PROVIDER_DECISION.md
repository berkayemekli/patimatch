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

## Implemented scaffold

Functions eklendi:

- `createVerificationSession` callable function
- `kycWebhook` HTTP function

UI eklendi:

- `IdentityVerificationPage` once callable function'i cagirir.
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
2. Bir KYC provider sec.
3. Secret/config ekle:
   - provider API key
   - provider webhook secret
   - default provider
4. Provider adapter'i `functions/index.js` icinde demo yerine bagla.
5. `firebase deploy --only functions --project prod` calistir.
6. Provider dashboard'da webhook URL tanimla:
   - `https://europe-west1-patimatch-app-2026-berkay.cloudfunctions.net/kycWebhook?provider=<provider>`
7. Test kullanicisiyle verified/rejected/needs_review akisini dene.

## Security rule

Firestore rules kullanicinin kendi `blueBadge`, `verificationStatus`, `verificationLevel`, `trustBadges` alanlarini yazmasini engelliyor. Bu alanlar sadece Admin SDK kullanan backend tarafindan guncellenebilir.
