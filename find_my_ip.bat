@echo off
setlocal enabledelayedexpansion
echo.
echo ========================================
echo   Finding Your PC's IP Address
echo ========================================
echo.

set FOUND=0
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    set IP=!IP: =!
    if not "!IP!"=="" (
        echo Your IP Address: !IP!
        set FOUND=1
    )
)

if %FOUND%==0 (
    echo No IPv4 address found. Make sure you're connected to a network.
)

echo.
echo ====================================
echo Use this IP in your Android app!
echo (NOT localhost or 127.0.0.1)
echo ====================================
echo.
echo If testing with Android Emulator, use: 10.0.2.2
echo.
pause
