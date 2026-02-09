@echo off
title SounDeck - USB Connection Setup
echo ====================================
echo  SounDeck USB Connection Helper
echo ====================================
echo.

echo Step 1: Enabling USB connection...
adb reverse tcp:8000 tcp:8000

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] USB port forwarding enabled!
    echo.
    echo Now in the app:
    echo   1. Open Settings
    echo   2. Enter IP: localhost
    echo   3. Enter Port: 8000
    echo   4. Tap Save
    echo.
    echo USB connection active! No WiFi needed!
) else (
    echo [ERROR] ADB connection failed!
    echo.
    echo Make sure:
    echo   1. Phone connected via USB
    echo   2. USB debugging enabled
    echo   3. ADB drivers installed
)

echo.
pause
