# Lite-Deck

A customizable soundboard application with a 24-key grid interface, featuring cross-platform keypress detection and real-time audio playback.

## Features

- **24-Key Grid Layout**: Intuitive grid interface for sound triggers
- **Custom Icons**: Support for custom button icons via image picker
- **Cross-Platform Backend**: Python/FastAPI backend with WebSocket communication
- **Non-Blocking Audio**: Smooth audio playback without UI freezes
- **Dark Theme**: Sleek dark interface with neon-green accents
- **Configuration**: JSON-based default key mappings

## Project Structure

```
lite-deck/
├── backend/              # Python FastAPI backend
│   ├── keyboard_handler.py
│   └── requirements.txt
├── lite_deck_flutter/    # Flutter Android app
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── pubspec.yaml
└── config.json          # Default configuration
```

## Setup

### Backend (Python)

```bash
cd backend
pip install -r requirements.txt
python keyboard_handler.py
```

### Mobile App (Flutter)

```bash
cd lite_deck_flutter
flutter pub get
flutter run
```

## Requirements

- **Backend**: Python 3.8+
- **Mobile**: Flutter 3.0+, Android 8+

## License

MIT License
