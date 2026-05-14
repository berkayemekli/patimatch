# PatiParent / PatiMatch

Flutter + Firebase tabanli PatiParent pet super app projesi.

Prod site: https://patiparent.com
GitHub repo: https://github.com/berkayemekli/patimatch

## Yeni laptop / yeni Codex baslangici

Yeni laptopta once repo'yu cek:

```powershell
git clone https://github.com/berkayemekli/patimatch.git C:\AI\Dog_Date
cd C:\AI\Dog_Date
```

Sonra Codex'e GitHub/repo icindeki su dosyayi okut:

- `CODEX_START_HERE.txt`

Kopyalamak istersen komut su:

```text
C:\AI\Dog_Date icindeki PROJECT_CONTEXT.md dosyasini oku.
Sonra SYNC_WORKFLOW.md ve TASKS.md dosyalarini oku.
Once git pull origin main, git status --short ve flutter analyze lib calistir.
Bana sormadan TASKS.md icindeki en yuksek oncelikli isi secip uygula.
Is bitince TASKS.md ve PROJECT_CONTEXT.md gerekiyorsa guncelle, commit ve push yap.
Google login icin PROJECT_CONTEXT.md icindeki notlari dikkate al.
```

## Baglam dosyalari

- `PROJECT_CONTEXT.md`: proje ozeti, teknik durum, Google login notlari, deploy komutlari.
- `SYNC_WORKFLOW.md`: iki laptop / iki Codex senkron calisma kurallari.
- `TASKS.md`: ortak is tahtasi.
- `DEPLOY_ENVIRONMENTS.md`: staging/prod deploy komutlari.
- `NEXT_CODEX_PROMPT.txt`: eski kisa baslangic promptu.
- `CODEX_START_HERE.txt`: yeni laptopta okutulacak en net baslangic dosyasi.

## Temel komutlar

```powershell
cd C:\AI\Dog_Date
git pull origin main
git status --short
cd app
flutter pub get
flutter analyze lib
```

Prod build/deploy:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=prod --pwa-strategy=none
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project prod
```

Staging build/deploy:

```powershell
cd C:\AI\Dog_Date\app
flutter build web --release --dart-define=APP_ENV=staging --pwa-strategy=none
cd C:\AI\Dog_Date
firebase.cmd deploy --only hosting --project staging
```

## Not

Eski README icerigi ilk MVP kurulumundan kalmaydi. Guncel calisma duzeni artik bu dosya ve baglam dosyalari uzerinden takip edilir.
