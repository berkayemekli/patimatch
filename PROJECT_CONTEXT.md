# PatiParent / PatiMatch Project Context

Bu dosya yeni laptopta veya yeni bir Codex sohbetinde projeye hizli devam etmek icin olusturuldu.

## Kisa ozet

PatiParent, Flutter + Firebase tabanli AI-native pet super app girisimidir. Urun 4 ana modulle ilerliyor:

- PatiGezdirme: kopek gezdirme / duzenli yuruyus / canli takip vizyonu.
- PatiBnB: seyahatlerde ev ortaminda pet konaklama / emanet.
- PatiMatch: Bumble benzeri pet eslesme, sosyal tanisma ve guvenli bulusma.
- PatiFamily: sahiplendirme, gecici yuva, aile olma yolculugu.

Konum: C:\AI\Dog_Date
Flutter app: C:\AI\Dog_Date\app
GitHub repo: https://github.com/berkayemekli/patimatch.git
Prod site: https://patiparent.com
Firebase prod project: patimatch-app-2026-berkay
Firebase staging project: patimatch-staging

## Tasarim vizyonu

Urun pet shop gibi degil, premium ve guven veren pet ebeveynligi ekosistemi gibi hissettirmeli.

Referans his:

- Airbnb seviyesinde guven
- Apple seviyesinde polish
- Uber gibi servis sadeligi
- Modern AI startup kalitesi

Kacinilacaklar:

- Cartoonish pet UI
- Ucuz marketplace hissi
- Fazla kutu/kart kalabaligi
- Eski dashboard gorunumu
- Sert borderlar ve gereksiz renk kalabaligi

## Mevcut teknik durum

- Flutter web/app.
- Firebase Auth, Firestore, Storage bagimli.
- Root firebase.json hosting public path olarak app/build/web kullaniyor.
- .firebaserc icinde prod ve staging aliaslari var.
- Hosting cache sorunlari icin deploy oncesi service worker cache-killer ile degistiriliyor.
- Master data dosyalari app/assets/master_data/ altinda ve pubspec.yaml icinde asset olarak dahil.

## Onemli dosyalar

- app/lib/main_shell_page.dart: ana modul shell/navigation.
- app/lib/login_page.dart: premium login ekrani, Google popup auth, Rony gorselli hero.
- app/lib/app_entry_page.dart: auth state giris yonlendirme.
- app/lib/pati_gezdirme_page.dart: PatiGezdirme filtre/kartlar.
- app/lib/pati_bnb_page.dart: PatiBnB filtre/kartlar.
- app/lib/pati_match_page.dart: PatiMatch temel yapi.
- app/lib/pati_parent_page.dart: PatiFamily/PatiParent sahiplendirme yapi.
- app/lib/data/master_data/master_data_repository.dart: sehir/ilce/cins data okuyucu.
- MARKETPLACE_BENCHMARK_NOTES.md: Airbnb/Armut/Sahibinden benchmark urun notlari.
- scripts/load_test_seed.js: staging load-test seed ve PatiMatch eslesme simulasyonu.

## Master data dosyalari

- animal_breeds_tr.json: kedi/kopek cinsleri, kirma/melez secenekleri, asi turleri.
- cities_districts_tr.json: Turkiye il/ilce data.
- service_types.json: 4 modul ve alt servis tipleri.
- marketplace_product_taxonomy.json: 4 modul icin profil, ilan, filtre, risk ve urun fikirleri.
- trust_safety_framework.json: dogrulama seviyeleri, guven rozetleri, fraud sinyalleri, safety checklist.
- pet_care_reference.json: kedi/kopek bakim, asi ve saglik referansi.
- content_seo_playbook.json: modul bazli SEO keyword, headline ve FAQ.
- onboarding_playbook.json: hizmet alan / hizmet veren / ikisini de kullanacak user onboarding akislari.
- seed_marketplace_examples.json: UI'a baglanabilecek ornek gezdirici, konaklama, match ve family ilanlari.
- veterinary_clinics_tr.json: OpenStreetMap kaynakli dogrulanmamis veteriner klinigi seed datası.
- pati_friendly_places_tr.json: OpenStreetMap dog/pets etiketlerinden dogrulanmamis pet dostu mekan seed datası.
- pet_groomers_tr.json: OpenStreetMap grooming/pet kuafor sinyallerinden dogrulanmamis pet kuaforu seed datasi.
- dog_trainers_tr.json: OpenStreetMap dog training/kopek egitimi sinyallerinden dogrulanmamis kopek egitmeni seed datasi.

## Son yapilanlar

- Load-test onerileri uygulandi: preflight, runId/TTL/cleanup, pipeline/CI, Auth Emulator, UI kontrat testleri, PatiMatch ag profilleri, yerel staging gorselleri, merkezi modul uyeligi ve HTML saglik paneli eklendi.
- Dort modulde 250'ser aktif staging uyeligi ve tam islem hacmi dogrulandi. Bagimsiz Firestore validator ve `docs/LOAD_TEST_PROCESS_RECOMMENDATIONS.md` surec raporu eklendi.
- Ana sayfa scroll hiyerarsisi duzeltildi; scrollbar artik dar icerik kolonunda degil viewport'un en saginda gorunuyor.
- Staging Firestore API/database acildi; load-test staging datasina 2720 dokuman yazildi. Data mapping raporu tam tablo sekmeleriyle yenilendi ve Takvim ust barda yazili aksiyon olarak gorunur hale getirildi.

- Load-test seed script eklendi; staging icin 4 modulde 250ser profil ve PatiMatch eslesme/chat simulasyonu uretebiliyor.

- Kopek egitmeni seed datasi eklendi; data mapping raporu bunu ileride PatiTraining alt basligi veya PatiCare destek katmani olarak konumlandiriyor.

- Takvim sayfas? eklendi; tarihli PatiGezdirme/PatiBnB talepleri listeleniyor ve Google Takvim linki a??l?yor.

- PatiGezdirme, PatiBnB ve PatiFamily detay panellerine tarih/rezervasyon secimi eklendi.

Son commitler:

- 540eaae Use popup flow for Google web sign-in
- 14e11d9 Add pet marketplace content data packs
- 536507c Add marketplace benchmark data model
- 4658393 Make module filters update listings
- 808abb5 Add search inside expanded filters
- 6bc740e Move Rony to lower right in login hero
- Data mapping raporu docs/data_mapping.html altinda guncellendi; veteriner ve pet dostu mekan katmani eklendi.
- Pet kuaforu seed datasi eklendi; data mapping raporu veteriner + kuafor + pet dostu mekanlari PatiCare/Yakinimda destek katmani olarak konumlandiriyor.

## Google login durumu

Google provider once kapaliydi. Firebase API OPERATION_NOT_ALLOWED: The identity provider configuration is not found donmustu.

Sonra provider acilinca redirect akisi su hatayi verdi:

Unable to process request due to missing initial state... signInWithRedirect in a storage-partitioned browser environment

Bu yuzden web Google login signInWithPopup akisine geri alindi. Eger hala calismazsa kontrol edilecekler:

- Firebase Console > Authentication > Sign-in method > Google enabled mi?
- Project support email secili mi?
- Authorized domains icinde bunlar var mi?
  - patiparent.com
  - www.patiparent.com
  - patimatch-app-2026-berkay.web.app
  - patimatch-app-2026-berkay.firebaseapp.com
- Chrome popup engelliyor mu?

Apple login su an aktif edilmeyecek. Apple Developer, Service ID, Team ID, Key ID ve private key ister. Simdilik Apple butonu sonraya birakildi.

## Deploy komutlari

PowerShell ile root klasorden:

```powershell
cd C:\AI\Dog_Date\app
flutter analyze lib
flutter build web --release --pwa-strategy=none
cd C:\AI\Dog_Date
# app/build/web/flutter_service_worker.js cache-killer icerigiyle degistirilir.
firebase.cmd deploy --only hosting --project prod
```

Git kayit:

```powershell
git status --short
git add <files>
git commit -m "message"
git push origin main
```

## Yeni laptopta baslangic

```powershell
git clone https://github.com/berkayemekli/patimatch.git C:\AI\Dog_Date
cd C:\AI\Dog_Date\app
flutter pub get
flutter analyze lib
```

Firebase CLI yoksa:

```powershell
npm install -g firebase-tools
firebase login
```

## Siradaki mantikli isler

1. Master data dosyalarini UI'a baglamak.
   - Veteriner, pet kuaforu, kopek egitmeni ve pet dostu mekan datasini PatiCare/Yakinimda harita/nearby discovery akisi icin zenginlestirmek.
2. Profil/onboarding ekranini hizmet alan / hizmet veren / ikisini de kullanacak sekilde yeniden kurmak.
3. PatiBnB ve PatiFamily kartlarini seed_marketplace_examples.json ile doldurmak.
4. PatiMatch'i Bumble benzeri kart stack + guest preview seklinde guclendirmek.
5. Google login'i gercek cihazda popup izniyle tekrar test etmek.
6. E-posta ile login/kayit eklemek. Google takilirsa MVP icin e-posta login daha stabil olabilir.
7. Staging/prod ayrimini build komutlariyla netlestirmek.

## Yeni Codex'e verilecek kisa komut

C:\AI\Dog_Date icindeki PROJECT_CONTEXT.md dosyasini oku. Bu Flutter + Firebase PatiParent projesinde son durumu, deploy komutlarini ve acik isleri oradan al. Once git status ve flutter analyze lib calistir, sonra master data dosyalarini UI/onboarding/filtrelere baglayarak devam et.
