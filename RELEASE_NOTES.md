# Dog Date MVP - Release Notes

## Tarih
- 2026-05-03

## Kapsam
- OTP login akisi ve auth tabanli giris yonlendirme
- Kopek profil olusturma/guncelleme
- Kesfet/swi̇pe (Begen/Gec) + kart stack + jest desteği
- Karsilikli begenide match olusturma
- Chat seed ve canli mesajlasma
- Matches listesi + unread badge
- Block/Report akislari
- Ayarlar sayfasi + cikis

## Onemli Teknik Iyilestirmeler
- Firestore payload standardizasyonu (`firestore_payloads.dart`)
- Repository katmani:
  - `swipe_repository.dart`
  - `chat_repository.dart`
  - `matches_repository.dart`
  - `user_repository.dart`
- Merkezi provider:
  - `app_providers.dart`
- Merkezi metin yonetimi:
  - `app_strings.dart`
- Discover tarafinda pagination ve filtre kaliciligi (`SharedPreferences`)
- Firestore rules ve indexes guncellendi/sikilastirildi

## Bilinen Notlar
- Yerel ortamda `flutter` komutu olmadigi durumlarda analyze/run dogrulamasi bu oturumda calistirilamadi.
- Deploy icin Firebase login ve aktif proje secimi gereklidir.
