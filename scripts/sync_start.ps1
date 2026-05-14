param(
  [switch]$Analyze = $true
)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repo

Write-Host '== PatiParent sync start ==' -ForegroundColor Cyan
Write-Host "Repo: $repo"

git pull origin main
$status = git status --short
if ($status) {
  Write-Host 'Working tree has local changes:' -ForegroundColor Yellow
  $status
} else {
  Write-Host 'Working tree clean.' -ForegroundColor Green
}

if ($Analyze) {
  Set-Location (Join-Path $repo 'app')
  Write-Host 'Running flutter pub get...' -ForegroundColor Cyan
  flutter pub get
  Write-Host 'Running flutter analyze lib...' -ForegroundColor Cyan
  flutter analyze lib
  Set-Location $repo
}

Write-Host '== Sync start complete ==' -ForegroundColor Green
