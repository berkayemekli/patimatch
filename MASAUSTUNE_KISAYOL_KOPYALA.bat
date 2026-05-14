@echo off
chcp 65001 >nul
cd /d C:\AI\Dog_Date

echo.
echo ===============================================
echo   PatiParent - Masaustune Kisayol Kopyala
echo ===============================================
echo.

set DESKTOP=%USERPROFILE%\Desktop
copy /Y "BASLAMADAN_ONCE_GITHUBDAN_CEK.bat" "%DESKTOP%\BASLAMADAN_ONCE_GITHUBDAN_CEK.bat" >nul
copy /Y "KAPATMADAN_ONCE_GITHUBA_YUKLE.bat" "%DESKTOP%\KAPATMADAN_ONCE_GITHUBA_YUKLE.bat" >nul

echo Masaustune iki dosya kopyalandi:
echo   BASLAMADAN_ONCE_GITHUBDAN_CEK.bat
echo   KAPATMADAN_ONCE_GITHUBA_YUKLE.bat
echo.
echo Bunlari iki PC'de de kullanabilirsin.
pause
