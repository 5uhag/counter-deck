@echo off
echo ========================================
echo   SounDeck - Install to Phone via ADB
echo ========================================
echo.

REM Check if ADB is available
adb version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] ADB not found!
    echo.
    echo Please install Android SDK Platform Tools:
    echo https://developer.android.com/tools/releases/platform-tools
    echo.
    echo Or enable USB debugging and Flutter will use its bundled ADB.
    pause
    exit /b 1
)

echo [1/4] Checking connected devices...
adb devices
echo.

echo [2/4] Building release APK...
cd counter_deck_flutter
flutter build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)
echo.

echo [3/4] Installing APK to phone...
adb install -r build\app\outputs\flutter-apk\app-release.apk
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Installation failed!
    echo Make sure:
    echo   - USB debugging is enabled on your phone
    echo   - Phone is connected via USB
    echo   - You authorized the computer on your phone
    pause
    exit /b 1
)
echo.

echo [4/4] Done!
echo.
echo ========================================
echo   App installed successfully!
echo ========================================
pause
