# Team Sync Workflow

Bu proje iki laptop / iki Codex ile calisilabilecek sekilde GitHub merkezli senkronize edilir.

## Altin kural

GitHub tek gercek kaynak kabul edilir. Yeni sohbete veya yeni cihaza baslarken once pull alinir, is bitince commit ve push yapilir.

## Her ise baslamadan once

PowerShell:

```powershell
cd C:\AI\Dog_Date
git pull origin main
git status --short
cd app
flutter pub get
flutter analyze lib
```

Eger calisma klasoru yeni laptopta yoksa:

```powershell
git clone https://github.com/berkayemekli/patimatch.git C:\AI\Dog_Date
cd C:\AI\Dog_Date\app
flutter pub get
flutter analyze lib
```


## Manuel yapmak istemiyorsan

Root klasorde cift tiklanabilir dosyalar var:

- `START_SYNC.bat`: ise baslarken calistir. `git pull`, `flutter pub get`, `flutter analyze lib` yapar.
- `FINISH_SYNC.bat`: isi bitirirken calistir. `flutter analyze lib`, `git add -A`, otomatik checkpoint commit ve `git push` yapar.
- `FINISH_SYNC_AND_DEPLOY_PROD.bat`: isi bitirirken prod'a da basar. Build, cache-killer, Firebase deploy, commit ve push yapar.

PowerShell ile ayni scriptler:

```powershell
cd C:\AI\Dog_Date
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_start.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_finish.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_finish.ps1 -DeployProd
```

Ozel commit mesaji vermek istersen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_finish.ps1 -Message "Refine PatiBnB filters"
```

## Her yeni Codex sohbetine verilecek komut

```text
C:\AI\Dog_Date icindeki PROJECT_CONTEXT.md dosyasini oku.
Sonra SYNC_WORKFLOW.md ve TASKS.md dosyalarini oku.
Once git pull origin main, git status --short ve flutter analyze lib calistir.
Bana sormadan TASKS.md icindeki en yuksek oncelikli isi secip uygula.
Is bitince TASKS.md ve PROJECT_CONTEXT.md gerekiyorsa guncelle, commit ve push yap.
```

## Cakismanin onune gecmek

Ayni anda iki Codex ayni dosyayi degistirmemeli. Is basinda TASKS.md icinde sahiplik yazilir.

Ornek:

```text
IN PROGRESS
- login_page.dart Google auth debug - Laptop 1
- pati_bnb_page.dart listing UI - Laptop 2
```

Dosya sahipligi yoksa once `git status --short` ve `git pull origin main` ile baslanir.

## Branch politikasi

Simdilik hizli MVP icin `main` uzerinde calisiliyor. Buyuk riskli refactorlarda branch acilabilir:

```powershell
git checkout -b codex/feature-name
```

Ama kullanici ozellikle istemedikce mevcut pratik: kucuk commitler + main'e push.

## Commit mesaji stili

Kisa ve davranis odakli:

- `Add onboarding data model`
- `Connect filters to listings`
- `Fix Google popup sign-in`
- `Refine PatiBnB cards`

## Deploy disiplini

Kucuk UI/data degisiklikleri icin:

1. `flutter analyze lib`
2. `flutter build web --release --pwa-strategy=none`
3. cache-killer service worker yaz
4. `firebase.cmd deploy --only hosting --project prod`
5. commit + push

Riskli islerde once staging kullan:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=staging --pwa-strategy=none
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project staging
```

Prod icin:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=prod --pwa-strategy=none
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project prod
```

## Cache-killer service worker

Flutter build sonrasi `app/build/web/flutter_service_worker.js` su basit cache temizleyiciyle degistirilebilir:

```javascript
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((key) => caches.delete(key)));
    if (self.registration && self.registration.unregister) {
      await self.registration.unregister();
    }
    const clientsList = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const client of clientsList) {
      client.navigate(client.url);
    }
  })());
});

self.addEventListener('fetch', () => {});
```

## Gun sonu checkpoint

Gun sonunda veya uzun isten sonra:

```powershell
git status --short
git add PROJECT_CONTEXT.md TASKS.md <changed-files>
git commit -m "Checkpoint project sync"
git push origin main
```

## Sorun halinde

- Once `git status --short` bak.
- Beklenmeyen dosya degisikligi varsa kullaniciya sor.
- Asla `git reset --hard` kullanma.
- Conflict cikarsa dosyayi okuyup sadece kendi degisikliklerini entegre et.
