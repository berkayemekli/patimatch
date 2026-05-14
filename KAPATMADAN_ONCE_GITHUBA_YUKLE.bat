@echo off
chcp 65001 >nul
cd /d C:\AI\Dog_Date

echo.
echo ===============================================
echo   PatiParent - Kapatmadan Once GitHub'a Yukle
echo ===============================================
echo.
echo Bu islem:
echo   1. Flutter analyze calistirir
echo   2. Tum degisiklikleri commitler
echo   3. GitHub'a push eder
echo.
echo Not: Siteye deploy etmez. Sadece GitHub senkronu yapar.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_finish.ps1 -Message "End of session sync"

echo.
echo Islem bitti. Bu pencereyi kapatabilirsin.
pause
