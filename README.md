# SounDeck 🎮🔊

A soundboard app for CS2 (and other games) - Control sounds from your phone and play them through your mic!

![Version](https://img.shields.io/badge/version-1.0.0-green)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows-blue)

## Features

- 🎵 **24 Sound Buttons** - Play sounds via phone or keyboard (Numpad 0-9, +, -, F5-F8)
- 📱 **Android App** - Beautiful dark-themed UI with neon-green accents
- 🔌 **WebSocket Connection** - Real-time sync between phone and PC
- 🎨 **Custom Icons** - Long-press buttons to set custom icons from your phone
- 🎙️ **Mic Modes** - Quick toggle between VB-CABLE (sounds) and real mic (voice)
- 🐛 **Debug Logging** - Built-in logger to troubleshoot connection issues
- 🌐 **Browser Integration** - Built-in browser for downloading sounds

## Quick Start

### Prerequisites

**If you don't have Python installed:**

1. **Download Python:**
   - Go to [python.org/downloads](https://www.python.org/downloads/)
   - Download Python 3.12 or newer
   
2. **Install Python:**
   - ✅ Check "Add Python to PATH" during installation
   - Click "Install Now"
   - Verify: Open cmd and type `python --version`

3. **Install VB-CABLE:**
   - Download from [vb-audio.com](https://vb-audio.com/Cable/)
   - Install and restart your PC
   - This creates a virtual audio cable for routing sounds to your mic

### Setup

1. **Clone/Download this repo**
   ```bash
   git clone <your-repo-url>
   cd counter-deck
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r backend/requirements.txt
   ```

3. **Add your sound files**
   - Put MP3/WAV files in `backend/sounds/`
   - Update `config.json` to map sounds to buttons

4. **Start the backend**
   ```bash
   python backend/main.py
   ```
   Or just double-click `start_soundeck.bat`

5. **Install Android app**
   - Download APK from Releases
   - Or build from source: `cd counter_deck_flutter && flutter build apk`

6. **Connect your phone**
   - Find your PC's IP: Run `find_my_ip.bat` or `ipconfig` in cmd
   - Open SounDeck app → Settings
   - Enter your PC's IP (e.g., 192.168.x.x)
   - Tap "Save & Connect"

## Configuration

Edit `config.json` to customize:

```json
{
  "backend": {
    "host": "0.0.0.0",
    "port": 8000,
    "audio_device": "CABLE Input (VB-Audio Virtual Cable)"
  },
  "buttons": [
    {
      "id": 1,
      "name": "Numpad 0",
      "key": "num_0",
      "sound": "backend\\sounds\\yourfile.mp3",
      "icon": ""
    }
  ]
}
```

Or run `soundeck_config.bat` for GUI config editor.

## Using in CS2

1. **Set CS2 microphone:**
   - Settings → Audio → Microphone Device
   - Select: **CABLE Output (VB-Audio Virtual Cable)**

2. **Play sounds:**
   - Press Numpad keys or F5-F8 on keyboard
   - OR tap buttons on phone app
   - Your teammates will hear the sounds!

3. **Switch back to voice:**
   - Change CS2 mic back to your real microphone
   - Or use the toggle tiles in the app

## Troubleshooting

### Phone can't connect?
1. Enable **Debug Logs** in Settings
2. Tap **View Logs** to see what's happening
3. Common issues:
   - Using "localhost" instead of PC's IP ❌
   - Phone and PC on different WiFi networks
   - Windows Firewall blocking connection
   - Backend not running

### Sounds not playing from phone?
- Check backend logs for "📱 Received button press"
- Verify sound files exist in `backend/sounds/`
- Make sure VB-CABLE is installed

### Keyboard detection not working?
- Backend must be running as administrator (for global hotkeys)
- Check if other apps are blocking keypresses

## Project Structure

```
counter-deck/
├── backend/              # Python FastAPI server
│   ├── main.py          # WebSocket server
│   ├── audio_player.py  # Sound playback
│   ├── keyboard_handler.py  # Hotkey detection
│   └── sounds/          # Your sound files go here
├── counter_deck_flutter/ # Android app
├── config.json          # Button/sound mappings
├── start_soundeck.bat   # Quick start script
└── find_my_ip.bat       # IP finder helper
```

## Tech Stack

- **Backend:** Python, FastAPI, WebSockets, pygame
- **Frontend:** Flutter, Dart
- **Audio:** VB-CABLE, pygame mixer

## Contributing

Pull requests welcome! Feel free to add features or fix bugs.

## License

MIT License - Use freely!

---

Made with ❤️ for CS2 soundboard enthusiasts
