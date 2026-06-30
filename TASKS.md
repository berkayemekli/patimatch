# PatiParent Tasks

Bu dosya iki laptop / iki Codex icin ortak is tahtasidir. Is baslamadan once `git pull origin main` yap ve bu dosyayi oku.

## In Progress

- Yok.

## Blocked / Needs External Action

- Firestore service/membership rules prod'a deploy edildi. Staging Service Usage bağlantısı başarısız olduğu için staging rules deploy tekrar denenmeli.
- Google login: Firebase Google provider acildiysa popup akisi kullaniliyor. Hala calismazsa Chrome popup izni ve Firebase Authentication > Sign-in method > Google ayarlari kontrol edilmeli.
- Apple login: Simdilik aktif edilmeyecek. Apple Developer, Service ID, Team ID, Key ID ve private key gerektirir.
- Cloud Functions deploy: Firebase Blaze plan gerekli. KYC backend scaffold hazir ama functions deploy Blaze olmadan tamamlanmiyor.

## Next Up

1. Unicorn sprint omurgasini baslat.
   - `docs/UNICORN_PRODUCT_STRATEGY.md` icindeki ilk 5 urun gelistirmesi uygulanacak.
   - Pet Passport v1: pet profili, asi, bakim notlari, paylasilabilir ozet.
   - Trust Score v1: kart/detail icinde guven skoru ve "neden guvenilir?" aciklamasi.
   - No Results Rescue: bos filtre sonucunda filtre temizle, yakin ilce, tumunu goster CTA.
   - What Happens Next: detay modalinda talep sonrasi surec timeline'i.
   - Report Card v1: tamamlanan hizmet sonrasi ozet formu ve chat ozeti.

2. Master data dosyalarini UI'a bagla.
   - `seed_marketplace_examples.json` PatiGezdirme/PatiBnB/PatiFamily kartlarina kaynak olsun.
   - `marketplace_product_taxonomy.json` filtre ve form alanlarini beslesin.
   - `trust_safety_framework.json` rozet/checklist alanlarini beslesin.
   - `veterinary_clinics_tr.json`, `pet_groomers_tr.json`, `dog_trainers_tr.json` ve `pati_friendly_places_tr.json` PatiCare/Yakinimda harita/nearby discovery icin kaynak olsun.
   - OSM kaynakli kayitlarda eksik il/ilce bilgisi koordinattan veya saglayici API ile zenginlestirilsin.
   - Her master data guncellemesinden sonra `python scripts/generate_data_mapping_report.py` calistirilip `docs/data_mapping.html` guncel tutulacak.

3. Onboarding akisini kur.
   - Hizmet almak istiyorum.
   - Hizmet vermek istiyorum.
   - Ikisini de kullanacagim.
   - Baslangicta zorunlu modal olmasin; ana sayfa gorulsun, login/profil tamamlama sonraya aksin.

4. E-posta ile giris/kayit ekle.
   - Google takilirsa MVP icin daha stabil fallback olur.
   - Login ekrani mevcut premium tasarimi korusun.

5. PatiMatch guest preview guclendir.
   - Uye olmadan kartlar gorulsun.
   - Bumble benzeri swipe hissi.
   - Guvenli eslesme/aciklama katmani.

6. PatiBnB Airbnb benzeri listing derinlestirme.
   - Ev tipi, bahce, baska pet var mi, ev kurallari, fiyat, uygunluk.
   - Daha gercekci ve yerel fotograf/icerik hissi.

7. PatiFamily sahiplendirme akisini derinlestir.
   - Acil yuva, gecici yuva, sahiplendirme formu, veteriner belgesi, takip gorusmesi.

8. Profil tamamlama skoru ekle.
   - `onboarding_playbook.json` icindeki weight modeli kullanilabilir.
   - Eksik alanlari yumuşak CTA olarak goster.

9. Staging/prod akisini pratiklestir.
   - `DEPLOY_ENVIRONMENTS.md` guncel.
   - Riskli isleri staging'e deploy et, onaydan sonra prod.

10. Mavi tik / kimlik dogrulama altyapisini kur.
   - Ucuncu parti KYC/IDV saglayici sec: Veriff, Sumsub, Persona, Onfido veya Stripe Identity.
   - Ham kimlik/yuz gorseli saklama; sadece verification sonucu ve provider reference tut.
   - Guven Merkezi UI: dogrulama baslat, pending, verified, rejected state.
   - Firestore rules: kullanici kendi `blueBadge` veya `verificationStatus` alanlarini dogrudan yazamasin.
   - Backend webhook: provider sonucuyla `users/{userId}` guncellensin.

## Done Recently

- SEO teknik kimligi duzeltildi: web title/description, canonical, OpenGraph/Twitter kartlari, schema.org JSON-LD, `robots.txt`, `sitemap.xml` ve Search Console checklist eklendi.
- Pati dostu otel kaynak envanteri ve ilk seed datası eklendi; `pet_friendly_hotels_tr.json` data mapping raporunda ayrı sekme olarak görünüyor.
- No Results Rescue v1 eklendi; PatiGezdirme, PatiBnB ve PatiFamily bos filtre sonucunda filtre temizleme ve esnek/yakin sonuc CTA'lari gosteriyor.
- Unicorn seviyesinde fark yaratacak urun stratejisi cikarildi: `docs/UNICORN_PRODUCT_STRATEGY.md`.
- PatiParent canlı UX akışı dünyadaki 10 güçlü ürünle karşılaştırıldı; analiz raporu `docs/global_ux_benchmark_2026.md` altında.
- Canlı UX ekran görüntülerini otomatik oynatan video player eklendi: `docs/live_ux_video_player.html`.
- Canlı site üzerinde gerçek tıklamalarla UX deneyim kaydı çıkarıldı; ekran görüntülü rapor `docs/live_ux_walkthrough.html` altında tutuluyor.
- Ürün akışlarını sayfa sayfa gösteren slayt/storyboard HTML'i eklendi: `docs/product_flow_slideshow.html`.
- Hizmet talebi kabul edilince alan/veren eşleşmesi, hizmet konuşması ve yaşam döngüsü takibi oluşturuluyor; ayrıntı `docs/SERVICE_MATCHING_FLOW_REPORT.md`.
- Load-test süreç önerileri sırayla uygulandı; uygulama kaydı `docs/LOAD_TEST_IMPLEMENTATION_PROGRESS.md` altında tutuluyor.
- Dört modül için 250'şer staging üyeliği ve işlem hacmi doğrulandı; bağımsız validator ve süreç geliştirme raporu eklendi.
- Ana modül sayfalarının scrollbar alanı içerik kutusundan çıkarıldı; web'de ekranın en sağında görünür ve tek sayfa scroll'u olarak çalışıyor.
- Gece load-test kosusu tamamlandi: staging Firestore API/database acildi, 2720 dokuman yazildi, `flutter analyze lib` temiz gecti.
- `docs/data_mapping.html` ust sekmeleri tam tablo listelerine baglandi; veteriner/kuafor/egitmen/pet dostu mekanlar isim-adres-telefon-web-harita alanlariyla kontrol edilebilir hale geldi.
- Takvim ana shell ust barinda yazili aksiyon olarak gorunur hale getirildi.

- Staging load-test seed script eklendi; 4 modul icin 250ser profil ve PatiMatch eslesme/chat simulasyonu dry-run ile dogrulandi.

- Kopek egitmeni OSM seed datasi eklendi; `docs/data_mapping.html` PatiTraining/PatiCare konumlandirmasini gosteriyor.

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
