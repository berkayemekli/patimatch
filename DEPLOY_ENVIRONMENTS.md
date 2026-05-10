# Deploy Environments (Staging / Prod)

## 1) Firebase projects
- `prod`: `patimatch-app-2026-berkay`
- `staging`: `<BURAYA_STAGING_PROJECT_ID>`

## 2) .firebaserc
`.firebaserc` dosyasina staging alias ekleyin:

```json
{
  "projects": {
    "default": "patimatch-app-2026-berkay",
    "prod": "patimatch-app-2026-berkay",
    "staging": "<BURAYA_STAGING_PROJECT_ID>"
  }
}
```

## 3) Web build commands
- Staging build:
```bash
flutter build web --release --dart-define=APP_ENV=staging
```
- Prod build:
```bash
flutter build web --release --dart-define=APP_ENV=prod
```

## 4) Hosting deploy commands
- Staging deploy:
```bash
firebase use staging
firebase deploy --only hosting
```
- Prod deploy:
```bash
firebase use prod
firebase deploy --only hosting
```

## 5) Current behavior
- `APP_ENV=staging` ile build edilirse ekranda `STAGING` badge cikar.
- `APP_ENV=prod` ile build edilirse badge gorunmez.

