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

7. PatiVet veri ve yorum altyapisini derinlestir.
   - Guvenilir kaynaklardan sehir/ilce bazli veteriner listesi topla.
   - Klinik sahiplenme/dogrulama akisi tasarla.
   - Puanlama, yorum, raporla ve moderasyon kurallarini ekle.
   - PatiVet verisini SQL analitik katmanina dahil et.

8. Profil tamamlama skoru ekle.
   - `onboarding_playbook.json` icindeki weight modeli kullanilabilir.
   - Eksik alanlari yumuşak CTA olarak goster.

9. Staging/prod akisini pratiklestir.
   - `DEPLOY_ENVIRONMENTS.md` guncel.
   - Riskli isleri staging'e deploy et, onaydan sonra prod.

10. Analytics event log ve admin rapor ekranini kur.
   - `DATABASE_ANALYTICS_PLAN.md` icindeki koleksiyon sozlugunu baz al.
   - SQL analitik katmani icin `analytics/bigquery/` dosyalarini baz al.
   - `analytics_events` repository ekle.
   - Login, pet profile save ve talep olusturma olaylarini event olarak yaz.
   - BigQuery dataset'i olusturup `schema.sql` ve `views.sql` dosyalarini calistir.
   - Baslangicta direkt Firestore sorgulariyla admin raporu goster.
   - Blaze/Cloud Functions aktif olunca `daily_metrics` ve `module_metrics` agregasyonlarini otomatiklestir.

11. Mobil uygulama ciktisi hazirla.
   - Flutter ayni kod tabanindan Android/iOS app uretecek.
   - Web UI stabil olduktan sonra Android build, ikon/splash, store metinleri ve test cihaz akisi hazirlanacak.

12. Mavi tik / kimlik dogrulama altyapisini kur.
   - Ucuncu parti KYC/IDV saglayici sec: Veriff, Sumsub, Persona, Onfido veya Stripe Identity.
   - Ham kimlik/yuz gorseli saklama; sadece verification sonucu ve provider reference tut.
   - Guven Merkezi UI: dogrulama baslat, pending, verified, rejected state.
   - Firestore rules: kullanici kendi `blueBadge` veya `verificationStatus` alanlarini dogrudan yazamasin.
   - Backend webhook: provider sonucuyla `users/{userId}` guncellensin.

## Done Recently

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
- Login hero Rony odakli guncellendi; mobil giriste de Rony gorseli gorunur hale geldi.
- Ana modul hero Rony gorseli ve guven odakli marka rozetiyle guncellendi.
- PatiBnB kartlari seed konaklama verisine baglandi; trust rozetleri, ev olanaklari, ev kurallari ve detay sheet'i derinlestirildi.
- PatiFamily kartlari seed familyListings verisine baglandi; aciliyet, uygun aile, trust ve sahiplendirme sureci sinyalleri eklendi.
- PatiGezdirme kartlari seed walker verisine baglandi; uzmanlik, canli takip ve guvenli yuruyus detaylari eklendi.
- Ayarlar ekrani hesap merkezi olarak yeniden tasarlandi; profil tamamlama bari, guven dogrulamasi ve temiz bolumlu aksiyonlar eklendi.
- Profili Duzenle ekraninda pet kaydi yoksa Rony baslangic taslagi ve gorseli otomatik doldurulacak hale getirildi.
- Database ve analitik raporlama plani eklendi; users, dogs, servis talepleri, analytics_events ve metrics koleksiyonlari tanimlandi. Odeme akisi uzun ilk donem icin ertelendi.
- Odeme giris noktalari ana ekrandan ve ayarlardan kaldirildi; ilk business modelde kullanicidan odeme alinmayacak.
- SQL tabanli analitik katmani baslatildi; BigQuery icin tablo semasi, view'lar ve hazir rapor sorgulari eklendi.
- Odeme sayfasi ve payment repository aktif koddan kaldirildi.
- PatiVet 5. ana modul olarak eklendi; starter veteriner veri sozlesmesi ve klinik kartlari baslatildi.
- Ana shell ve ayarlar/profil ekranlarinda scroll alani tam sayfaya yayildi.

## Ownership Template

Is baslarken buraya ekle:

```text
IN PROGRESS
- <task> - <device/codex> - files: <file list>
```

Is bitince `Done Recently` altina tasi ve commit hash'i ekle.
