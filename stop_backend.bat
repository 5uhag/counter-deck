@echo off
echo ========================================
echo   Killing All SounDeck Processes
echo ========================================
echo.

python backend\kill_soundeck.py

if %errorlevel% equ 0 (
    echo.
    echo All SounDeck processes stopped.
) else (
    echo.
    echo Failed to kill processes.
)

timeout /t 3 >nul
