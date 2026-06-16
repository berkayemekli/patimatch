# PatiParent Tasks

Bu dosya iki laptop / iki Codex icin ortak is tahtasidir. Is baslamadan once `git pull origin main` yap ve bu dosyayi oku.

## In Progress

- Yok.

## Blocked / Needs External Action

- Google login: Firebase Google provider acildiysa popup akisi kullaniliyor. Hala calismazsa Chrome popup izni ve Firebase Authentication > Sign-in method > Google ayarlari kontrol edilmeli.
- Apple login: Simdilik aktif edilmeyecek. Apple Developer, Service ID, Team ID, Key ID ve private key gerektirir.
- Cloud Functions deploy: Firebase Blaze plan gerekli. KYC backend scaffold hazir ama functions deploy Blaze olmadan tamamlanmiyor.

## Next Up

1. Master data dosyalarini UI'a bagla.
   - `seed_marketplace_examples.json` PatiGezdirme/PatiBnB/PatiFamily kartlarina kaynak olsun.
   - `marketplace_product_taxonomy.json` filtre ve form alanlarini beslesin.
   - `trust_safety_framework.json` rozet/checklist alanlarini beslesin.
   - `veterinary_clinics_tr.json`, `pet_groomers_tr.json` ve `pati_friendly_places_tr.json` PatiCare/Yakinimda harita/nearby discovery icin kaynak olsun.
   - OSM kaynakli kayitlarda eksik il/ilce bilgisi koordinattan veya saglayici API ile zenginlestirilsin.
   - Her master data guncellemesinden sonra `python scripts/generate_data_mapping_report.py` calistirilip `docs/data_mapping.html` guncel tutulacak.

2. Onboarding akisini kur.
   - Hizmet almak istiyorum.
   - Hizmet vermek istiyorum.
   - Ikisini de kullanacagim.
   - Baslangicta zorunlu modal olmasin; ana sayfa gorulsun, login/profil tamamlama sonraya aksin.

3. E-posta ile giris/kayit ekle.
   - Google takilirsa MVP icin daha stabil fallback olur.
   - Login ekrani mevcut premium tasarimi korusun.

4. PatiMatch guest preview guclendir.
   - Uye olmadan kartlar gorulsun.
   - Bumble benzeri swipe hissi.
   - Guvenli eslesme/aciklama katmani.

5. PatiBnB Airbnb benzeri listing derinlestirme.
   - Ev tipi, bahce, baska pet var mi, ev kurallari, fiyat, uygunluk.
   - Daha gercekci ve yerel fotograf/icerik hissi.

6. PatiFamily sahiplendirme akisini derinlestir.
   - Acil yuva, gecici yuva, sahiplendirme formu, veteriner belgesi, takip gorusmesi.

7. Profil tamamlama skoru ekle.
   - `onboarding_playbook.json` icindeki weight modeli kullanilabilir.
   - Eksik alanlari yumuşak CTA olarak goster.

8. Staging/prod akisini pratiklestir.
   - `DEPLOY_ENVIRONMENTS.md` guncel.
   - Riskli isleri staging'e deploy et, onaydan sonra prod.

9. Mavi tik / kimlik dogrulama altyapisini kur.
   - Ucuncu parti KYC/IDV saglayici sec: Veriff, Sumsub, Persona, Onfido veya Stripe Identity.
   - Ham kimlik/yuz gorseli saklama; sadece verification sonucu ve provider reference tut.
   - Guven Merkezi UI: dogrulama baslat, pending, verified, rejected state.
   - Firestore rules: kullanici kendi `blueBadge` veya `verificationStatus` alanlarini dogrudan yazamasin.
   - Backend webhook: provider sonucuyla `users/{userId}` guncellensin.

## Done Recently

- Takvim sayfas? eklendi; PatiGezdirme/PatiBnB talepleri tek yerde listeleniyor ve Google Takvim linki ?retilebiliyor.

- PatiGezdirme, PatiBnB ve PatiFamily detay ak??lar?na tarih/rezervasyon se?imi eklendi; talepler se?ilen tarih bilgisiyle kaydediliyor.

- Pet kuaforu OSM seed datasi eklendi; `docs/data_mapping.html` veteriner + kuafor + pet dostu mekanlari PatiCare/Yakinimda destek katmani olarak gosteriyor.

- Proje baglami icin `PROJECT_CONTEXT.md` eklendi.
- Yeni Codex baslangic komutu icin `NEXT_CODEX_PROMPT.txt` eklendi.
- Data paketleri eklendi:
  - `marketplace_product_taxonomy.json`
  - `trust_safety_framework.json`
  - `pet_care_reference.json`
  - `content_seo_playbook.json`
  - `onboarding_playbook.json`
  - `seed_marketplace_examples.json`
- Filtrelere arama eklendi.
- Filtrelerin listeleri gercekten etkilemesi saglandi.
- Google web login redirect yerine popup akisine alindi.
- PatiMatch kart kuyrugu `seed_marketplace_examples.json` verisinden beslenmeye basladi.
- Mavi tik / kimlik dogrulama icin `IDENTITY_VERIFICATION_PLAN.md` ve `identity_verification_blue_badge.json` eklendi.
- Ayarlar altina Profil ve Guven dogrulamasi sayfasi eklendi; Firestore rules mavi tik alanlarini koruyacak sekilde deploy edildi.
- KYC backend scaffold eklendi: callable session creation + webhook iskeleti. Functions deploy Blaze plan bekliyor.
- Veriff hosted KYC adapter kodu eklendi; `VERIFF_API_KEY` secret ve Blaze plan sonrasi gercek kimlik/yuz dogrulama linki acilacak.
- Laptop branch'indeki veteriner klinikleri ve pet dostu mekan seed verileri main'e tasindi; data mapping raporuna eklendi.
- `docs/data_mapping.html` icin tekrar uretilebilir generator eklendi: `scripts/generate_data_mapping_report.py`.
- PatiBnB ve PatiFamily kart/profil gorunurlugu duzeltildi; Firestore kayitlari ile zengin demo ornekleri birlikte gosteriliyor.

## Ownership Template

Is baslarken buraya ekle:

```text
IN PROGRESS
- <task> - <device/codex> - files: <file list>
```

Is bitince `Done Recently` altina tasi ve commit hash'i ekle.
