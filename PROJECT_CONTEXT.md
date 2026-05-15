# PatiParent / PatiMatch Project Context

Bu dosya yeni laptopta veya yeni bir Codex sohbetinde projeye hizli devam etmek icin olusturuldu.

## Kisa ozet

PatiParent, Flutter + Firebase tabanli AI-native pet super app girisimidir. Urun 5 ana modulle ilerliyor:

- PatiGezdirme: kopek gezdirme / duzenli yuruyus / canli takip vizyonu.
- PatiBnB: seyahatlerde ev ortaminda pet konaklama / emanet.
- PatiMatch: Bumble benzeri pet eslesme, sosyal tanisma ve guvenli bulusma.
- PatiFamily: sahiplendirme, gecici yuva, aile olma yolculugu.
- PatiVet: sehir bazli veteriner kesfi, puanlama, yorum ve klinik listeleme vizyonu.

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
- app/lib/pati_vet_page.dart: PatiVet veteriner kesif ve yorum altyapisi.
- app/lib/data/master_data/master_data_repository.dart: sehir/ilce/cins data okuyucu.
- MARKETPLACE_BENCHMARK_NOTES.md: Airbnb/Armut/Sahibinden benchmark urun notlari.
- DATABASE_ANALYTICS_PLAN.md: Firestore koleksiyonlari, analitik event modeli ve rapor ekrani plani.
- analytics/bigquery/: SQL tabanli BigQuery analitik semasi, view'lar ve ornek rapor sorgulari.

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
- veterinary_clinics_tr.json: PatiVet icin starter klinik veri sozlesmesi.

## Son yapilanlar

Son commitler:

- 540eaae Use popup flow for Google web sign-in
- 14e11d9 Add pet marketplace content data packs
- 536507c Add marketplace benchmark data model
- 4658393 Make module filters update listings
- 808abb5 Add search inside expanded filters
- 6bc740e Move Rony to lower right in login hero
- Login hero mobilde de Rony gorselini gosterecek sekilde sade ve premium hale getirildi.
- Ana modul hero generic uzak gorsel yerine Rony asset'i ve guven odakli marka rozetiyle guncellendi.
- PatiBnB kartlari seed_marketplace_examples.json konaklama verisiyle beslenmeye ve Airbnb benzeri trust/ev kurali detaylari gostermeye basladi.
- PatiFamily kartlari seed familyListings verisine baglandi; aciliyet, uygunluk, trust ve sahiplendirme sureci detaylari eklendi.
- PatiGezdirme kartlari seed walkers verisine baglandi; uzmanlik, canli takip ve yuruyus guvenligi detaylari eklendi.
- Ayarlar ekrani hesap merkezi olarak yeniden tasarlandi; profil tamamlama bari, guven dogrulamasi ve bolumlu aksiyon yapisi eklendi.
- Profili Duzenle ekraninda kullaniciya ait pet kaydi yoksa Rony baslangic taslagi ve gorseli otomatik doldurulacak hale getirildi.
- Database ve analitik raporlama plani eklendi; users, dogs, servis talepleri, analytics_events ve metrics koleksiyonlari tanimlandi. Odeme akisi uzun ilk donem icin ertelendi.
- Odeme giris noktalari ana ekrandan ve ayarlardan kaldirildi; ilk business modelde kullanicidan odeme alinmayacak.
- SQL tabanli analitik katmani baslatildi; BigQuery icin `schema.sql`, `views.sql` ve hazir rapor sorgulari eklendi.
- Odeme sayfasi ve payment repository aktif koddan kaldirildi.
- PatiVet 5. ana modul olarak eklendi; starter veteriner veri sozlesmesi ve klinik kartlari baslatildi.
- Ana shell ve ayarlar/profil ekranlarinda scroll alani tam sayfaya yayildi.

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
2. Profil/onboarding ekranini hizmet alan / hizmet veren / ikisini de kullanacak sekilde yeniden kurmak.
3. PatiBnB ve PatiFamily kartlarini seed_marketplace_examples.json ile doldurmak.
4. PatiMatch'i Bumble benzeri kart stack + guest preview seklinde guclendirmek.
5. Google login'i gercek cihazda popup izniyle tekrar test etmek.
6. E-posta ile login/kayit eklemek. Google takilirsa MVP icin e-posta login daha stabil olabilir.
7. Staging/prod ayrimini build komutlariyla netlestirmek.
8. Analytics event log ve admin rapor ekranini kurmak.

## Yeni Codex'e verilecek kisa komut

C:\AI\Dog_Date icindeki PROJECT_CONTEXT.md dosyasini oku. Bu Flutter + Firebase PatiParent projesinde son durumu, deploy komutlarini ve acik isleri oradan al. Once git status ve flutter analyze lib calistir, sonra master data dosyalarini UI/onboarding/filtrelere baglayarak devam et.
