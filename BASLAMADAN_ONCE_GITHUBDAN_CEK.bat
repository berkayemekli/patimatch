@echo off
chcp 65001 >nul
cd /d C:\AI\Dog_Date

echo.
echo ===============================================
echo   PatiParent - Baslamadan Once GitHub'dan Cek
echo ===============================================
echo.
echo Bu islem:
echo   1. GitHub'daki son hali ceker
echo   2. Flutter pub get calistirir
echo   3. Flutter analyze calistirir
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_start.ps1

echo.
echo Hazir. Calismaya baslayabilirsin.
pause
