@echo off
title Hitomi Voice Service ^<3
echo ==========================================
echo    Menghidupkan suara Hitomi...
echo ==========================================
powershell -ExecutionPolicy Bypass -File "%~dp0Hitomi_Voice_Service.ps1"
pause
