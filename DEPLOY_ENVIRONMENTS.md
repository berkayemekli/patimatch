# Deploy Environments (Staging / Prod)

## Firebase projects

- `prod`: `patimatch-app-2026-berkay`
- `staging`: `patimatch-staging`

## .firebaserc

Root `.firebaserc` su anda bu aliaslari icerir:

```json
{
  "projects": {
    "default": "patimatch-app-2026-berkay",
    "prod": "patimatch-app-2026-berkay",
    "staging": "patimatch-staging"
  }
}
```

## Web build commands

Staging build:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=staging --pwa-strategy=none
```

Prod build:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=prod --pwa-strategy=none
```

## Hosting deploy commands

Staging deploy:

```powershell
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project staging
```

Prod deploy:

```powershell
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project prod
```

## Current behavior

- `APP_ENV=staging` ile build edilirse ekranda `STAGING` badge cikar.
- `APP_ENV=prod` ile build edilirse badge gorunmez.

## Recommended flow

- Buyuk/riskli UI veya auth degisikligi: once staging.
- Kucuk data veya metin degisikligi: analyze + prod deploy kabul edilebilir.
- Her deploy sonrasi Git commit/push yap.
