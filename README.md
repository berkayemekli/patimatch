# PatiMatch Setup (Windows)

Bu klasörden ilerle:

```powershell
cd C:\AI\Invest
```

## 1) Gerekli araçlar

1. Node.js LTS (18+)
2. Flutter SDK (stable)
3. Firebase CLI

Kurulum kontrolü:

```powershell
node -v
npm -v
flutter --version
firebase --version
```

Firebase CLI yoksa:

```powershell
npm install -g firebase-tools
```

## 2) Firebase proje bağlama

```powershell
firebase login
firebase use --add
```

Komut, projeyi seçip bu klasöre alias yazar.

## 3) Firestore kuralları ve indexleri deploy et

```powershell
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## 4) Örnek veri seed et (opsiyonel)

```powershell
npm install
node scripts/seed.js
```

Not:
- `scripts/seed.js` için service account gerekir.
- `GOOGLE_APPLICATION_CREDENTIALS` ortam değişkenine JSON path ver.

Örnek:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\serviceAccountKey.json"
node scripts/seed.js
```

## 5) Flutter app başlatma (MVP iskelet)

Yeni Flutter app oluştur:

```powershell
flutter create patimatch_app
cd patimatch_app
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
```

Firebase bağlantısı:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Çalıştır:

```powershell
flutter run
```

## 6) İlk geliştirme sırası

1. OTP login ekranı
2. `users` yazma
3. `dogs` profil oluşturma
4. keşfet ekranı (dummy + Firestore query)
5. swipe write (`swipes`)
6. çift taraflı like -> `matches`

