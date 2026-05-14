param(
  [string]$Message = "Checkpoint sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
  [switch]$DeployProd = $false,
  [switch]$Analyze = $true
)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repo

Write-Host '== PatiParent sync finish ==' -ForegroundColor Cyan
Write-Host "Repo: $repo"

if ($Analyze) {
  Set-Location (Join-Path $repo 'app')
  Write-Host 'Running flutter analyze lib...' -ForegroundColor Cyan
  flutter analyze lib
  Set-Location $repo
}

if ($DeployProd) {
  Set-Location (Join-Path $repo 'app')
  Write-Host 'Building web prod...' -ForegroundColor Cyan
  flutter build web --release --dart-define=APP_ENV=prod --pwa-strategy=none
  Set-Location $repo
  $serviceWorker = @"
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
"@
  $serviceWorker | Set-Content -Path app\build\web\flutter_service_worker.js -Encoding UTF8
  Write-Host 'Deploying Firebase Hosting prod...' -ForegroundColor Cyan
  firebase.cmd deploy --only hosting --project prod
}

$status = git status --short
if (-not $status) {
  Write-Host 'No changes to commit. Pulling latest to stay current...' -ForegroundColor Yellow
  git pull origin main
  Write-Host '== Nothing to push ==' -ForegroundColor Green
  exit 0
}

Write-Host 'Staging changes...' -ForegroundColor Cyan
git add -A

Write-Host "Committing: $Message" -ForegroundColor Cyan
git commit -m $Message

Write-Host 'Pushing to origin main...' -ForegroundColor Cyan
git push origin main

Write-Host '== Sync finish complete ==' -ForegroundColor Green
