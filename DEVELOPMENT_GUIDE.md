# SounDeck Development Guide

## 🚀 Quick Commands for Development

### Installing to Phone via Terminal

#### Method 1: One Command (Recommended)
```bash
# From project root
install_to_phone.bat
```

This script will:
1. Build the release APK
2. Install it to your connected phone via ADB

#### Method 2: Manual Commands

**Build APK:**
```bash
cd counter_deck_flutter
flutter build apk --release --no-tree-shake-icons
```

**Install to Phone:**
```bash
adb install -r counter_deck_flutter\build\app\outputs\flutter-apk\app-release.apk
```

The `-r` flag means "replace existing app" (update).

---

## 📱 Setting Up ADB (One-time Setup)

### Enable USB Debugging on Redmi Note 10 Pro

1. **Enable Developer Options:**
   - Go to **Settings** → **About phone**
   - Tap **MIUI version** 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to **Settings** → **Additional settings** → **Developer options**
   - Enable **USB debugging**
   - Enable **Install via USB** (makes installation easier)

3. **Connect Phone:**
   - Connect via USB cable
   - On phone, select **File Transfer** mode
   - Grant USB debugging permission when prompted

### Verify ADB Connection

```bash
adb devices
```

You should see your device listed:
```
List of devices attached
abc12345    device
```

If it shows `unauthorized`, check your phone for the authorization prompt.

---

## 🔥 Hot Reload During Development

For rapid development, you can use Flutter's hot reload feature:

### Start Development Server
```bash
cd counter_deck_flutter
flutter run
```

This will:
- Install the app on your connected phone
- Watch for code changes
- Allow hot reload with `r` key
- Allow hot restart with `R` key
- Allow quit with `q` key

**Hot Reload Commands:**
- `r` - Hot reload (instant update, preserves state)
- `R` - Hot restart (full restart)
- `q` - Quit

### Example Development Workflow:
```bash
# Terminal 1 - Run app with hot reload
cd counter_deck_flutter
flutter run

# Make changes to your code...
# Press 'r' in terminal to hot reload
# Press 'R' for full restart
# Press 'q' to quit
```

---

## 🛠️ Common Commands

### Build Commands
```bash
# Release APK (production)
flutter build apk --release --no-tree-shake-icons

# Debug APK (with debugging symbols)
flutter build apk --debug

# Clean build (if having issues)
flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

### ADB Commands
```bash
# List connected devices
adb devices

# Install APK (replace if exists)
adb install -r path\to\app.apk

# Uninstall app
adb uninstall com.example.counter_deck_flutter

# View device logs
adb logcat

# View only Flutter logs
adb logcat | findstr "flutter"
```

### Flutter Commands
```bash
# Get dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build for release
flutter build apk --release
```

---

## 🎯 Quick Development Tips

### 1. Use Hot Reload for Fast Iteration
Instead of rebuilding and reinstalling every time:
```bash
flutter run
# Make changes
# Press 'r' to hot reload (< 1 second)
```

### 2. View Real-time Logs
```bash
# Terminal 1
flutter run

# Terminal 2 (optional - detailed logs)
adb logcat | findstr "flutter"
```

### 3. Test on Multiple Devices
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 📦 Release Workflow

### Full Build and Install
```bash
# Option 1: Use the batch script
install_to_phone.bat

# Option 2: Manual commands
cd counter_deck_flutter
flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

---

## 🐛 Troubleshooting

### ADB Not Found
- Flutter includes ADB, so if `flutter run` works, you can use Flutter's ADB:
  ```bash
  flutter run
  ```
- Or install Android SDK Platform Tools separately

### Device Not Detected
```bash
adb kill-server
adb start-server
adb devices
```

### Installation Failed
- Make sure USB debugging is enabled
- Check if your phone shows authorization dialog
- Try different USB cable or port
- Disable and re-enable USB debugging

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release --no-tree-shake-icons
```

---

## ⚡ Pro Tips

1. **Fast Testing:** Use `flutter run` instead of building APK every time
2. **Hot Reload:** Press `r` for instant updates without losing app state
3. **Wireless Debugging:** You can use ADB over WiFi (advanced)
4. **Multiple Devices:** Test on emulator and physical device simultaneously
5. **Quick Install:** Use the `install_to_phone.bat` script for one-command deployment

---

## 📝 Summary of Terminal Commands

```bash
# Development (with hot reload)
cd counter_deck_flutter
flutter run              # Press 'r' for hot reload, 'q' to quit

# Quick Deploy
install_to_phone.bat     # Builds and installs in one command

# Manual Deploy
cd counter_deck_flutter
flutter build apk --release --no-tree-shake-icons
adb install -r build\app\outputs\flutter-apk\app-release.apk

# Check Setup
adb devices             # Verify phone is connected
flutter doctor          # Check Flutter installation
```
