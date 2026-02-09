@echo off
echo ====================================
echo Finding your PC's IP Address...
echo ====================================
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    echo Your IP Address: %%a
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
