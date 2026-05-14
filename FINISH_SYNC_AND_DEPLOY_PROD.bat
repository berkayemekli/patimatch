@echo off
cd /d C:\AI\Dog_Date
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync_finish.ps1 -DeployProd
pause
