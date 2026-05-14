# Cloud Workflow

Bu proje iki PC arasinda manuel senkronla ugrasmamak icin GitHub merkezli calisacak sekilde ayarlandi.

## En basit mantik

- Kod GitHub'a gider.
- GitHub Actions otomatik `flutter analyze lib` calistirir.
- Build alir.
- Firebase Hosting'e prod deploy yapar.
- Boylece her bilgisayarda ayri ayri deploy scripti calistirmak gerekmez.

## GitHub'da calismak

Yeni laptopta lokal kurulumla ugrasmadan calismak icin GitHub Codespaces kullanilabilir:

1. GitHub repo'yu ac: https://github.com/berkayemekli/patimatch
2. `Code` butonuna bas.
3. `Codespaces` sekmesini sec.
4. `Create codespace on main` de.
5. Codespace acilinca terminalde:

```bash
cd app
flutter analyze lib
```

`.devcontainer/devcontainer.json` Flutter image kullanacak sekilde eklendi. Codespace acildiginda `cd app && flutter pub get` otomatik calisir.

## Otomatik deploy

`.github/workflows/deploy-hosting.yml` su anda `main` branch'e her push geldiginde:

1. Checkout
2. Flutter setup
3. `flutter pub get`
4. `flutter analyze lib`
5. `flutter build web --release --dart-define=APP_ENV=prod --pwa-strategy=none`
6. cache-killer service worker yazimi
7. Firebase Hosting live deploy

## Gereken GitHub Secret

Deploy icin GitHub repo secrets icinde su secret gerekli:

```text
FIREBASE_SERVICE_ACCOUNT_PATIMATCH_APP_2026_BERKAY
```

Bu secret yoksa GitHub Actions build alir ama Firebase deploy adiminda takilir.

## Lokal PC'ler ne yapacak?

Tamamen GitHub/Codespaces uzerinden calisirsan lokal PC'lerde script calistirmana gerek kalmaz.

Lokal calismak istersen yine su dosyalar duruyor:

- `START_SYNC.bat`
- `FINISH_SYNC.bat`
- `FINISH_SYNC_AND_DEPLOY_PROD.bat`

Ama cloud workflow tercihinde ana rutin:

1. GitHub Codespaces'te degisikligi yap.
2. Commit + push.
3. GitHub Actions otomatik analyze/build/deploy yapsin.

## Onemli ayrim

- `git push`: GitHub'a kod kaydeder.
- GitHub Actions: push gelince otomatik deploy eder.
- `firebase deploy`: artik manuel mecburi degil, Action yapiyor.

## Risk notu

Main'e her push prod'a deploy eder. Bu hizli MVP icin rahat ama buyuk riskli islerde ileride PR/staging kurali eklenebilir.
