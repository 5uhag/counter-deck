@echo off
title SounDeck Backend
cd /d "%~dp0backend"

echo ========================================
echo   SounDeck Backend - Minimal Mode
echo ========================================
echo.
echo Starting headless server...
echo Press CTRL+C to stop
echo.

python main.py

pause
