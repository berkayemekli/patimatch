# Identity Verification / Blue Badge Plan

PatiParent icinde mavi tikli kullanici yaratmak icin kimlik okutma + yuz/liveness dogrulamasi gerekli olabilir. Bu alan biyometrik veri icerdigi icin urun ve teknik mimari dikkatli kurulmalidir.

## Karar

Ham kimlik fotografi, selfie, yuz vektoru veya biyometrik template PatiParent Firestore/Storage icinde saklanmayacak.

Dogrulama ucuncu parti KYC/IDV saglayici ile yapilacak. Uygulama sadece sonucu saklayacak:

- `verificationStatus`
- `verificationLevel`
- `verificationProvider`
- `verificationSessionId`
- `verifiedAt`
- `verificationExpiresAt`
- `blueBadge`
- `trustBadges`

## Degerlendirilecek saglayicilar

- Veriff
- Sumsub
- Persona
- Onfido
- Stripe Identity alternatif olarak degerlendirilebilir

Secim kriterleri:

- Turkiye kimlik/pasaport destek durumu
- Web + mobile SDK
- Hosted verification link destegi
- Webhook/API kalitesi
- KVKK/GDPR sozlesme ve data residency secenekleri
- Fiyat / dogrulama basina maliyet
- Manuel inceleme ve itiraz sureci

## MVP akisi

1. Kullanici Guven Merkezi sayfasina girer.
2. Mavi tik faydalari gosterilir.
3. KVKK aydinlatma ve acik riza gosterilir.
4. Backend verification session olusturur.
5. Kullanici provider ekraninda kimlik + selfie/liveness tamamlar.
6. Provider webhook sonucu backend'e gonderir.
7. Backend `users/{userId}` alanlarini gunceller.
8. UI kartlarda mavi tik ve dogrulama rozetleri gosterilir.

## UI alanlari

- Profil kartinda mavi tik.
- Hizmet veren kartinda `Kimlik dogrulandi` rozeti.
- PatiBnB host kartinda `Konum/Kimlik dogrulandi`.
- PatiMatch'te `Sahip dogrulandi`.
- PatiFamily'de `Ilan sahibi dogrulandi`.

## KVKK notu

KVKK Madde 6 kapsaminda biyometrik veri ozel nitelikli kisisel veridir. Bu nedenle veri minimizasyonu, acik riza, saklama suresi, silme/itiraz sureci ve saglayici sozlesmeleri netlesmeden ham biyometrik veri islenmemelidir.

## Ilk teknik isler

- `identity_verification_blue_badge.json` data modeli eklendi.
- Firestore rules icinde kullanicinin kendi verification status alanlarini dogrudan yazmasi engellenmeli.
- Cloud Functions veya guvenilir backend webhook ile status guncellenmeli.
- UI tarafinda simdilik provider secilene kadar `Dogrulama yakinda` veya demo pending/verified state kurulabilir.
