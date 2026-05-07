# Dog Date MVP - Smoke Results

## Test Modu
- Bu oturumda `flutter` komutu ortamda bulunamadigi icin UI/runtime smoke adimlari cihazda calistirilamadi.
- Sonuclar ikiye ayrilmistir:
  - `PASS (Code-level)`: Kod tabaninda ozellik varligi dogrulandi.
  - `PENDING (Runtime)`: Gercek cihaz/emulator uzerinde dogrulanmasi gerekiyor.

## PASS (Code-level)
- Auth yonlendirme giris noktasi: `AppEntryPage` (`authStateChanges`) mevcut.
- Login / Profil / Discover gecis akisi mevcut.
- Discover swipe mimarisi:
  - Saga/sola swipe (`Dismissible`)
  - `Undo` aksiyonu
  - Sehir filtresi + verified-only filtre
  - Filtre kaliciligi (`SharedPreferences`)
- Match olusumu:
  - Karsilikli begeni kontrolu + `matches` ve `chats` yazimi
- Chat:
  - Mesaj gonderme
  - Soft delete
  - Mesaj raporlama
  - Kullanici engelleme
  - Anti-spam guard
- Matches:
  - Kullaniciya gore eslesme stream
  - Chat preview + unread badge mantigi
  - Block filtresi
- Firestore:
  - `firestore.rules` sikilastirilmis
  - `firestore.indexes.json` discover/matches sorgulari icin guncel

## PENDING (Runtime)
- OTP login gercek SMS dogrulamasi
- Profil fotograf upload akisi (storage izinleri dahil)
- Discover kartlariyla canli swipe + undo davranisi
- Karsilikli begenide anlik match modal davranisi
- Chat canli mesajlasma ve saat gorunumu
- Long-press aksiyonlari (copy/report/delete)
- Block akisinin tum ekranlarda anlik yansimasi
- Report kayitlarinin panelde gorulmesi
- Rules/index deploy sonrasi index hata kontrolu

## Onerilen Komutlar (Senin Ortaminda)
```powershell
cd C:\AI\Dog_Date\app
flutter pub get
flutter run
```

```powershell
cd C:\AI\Dog_Date
firebase deploy --only firestore:rules,firestore:indexes
```
