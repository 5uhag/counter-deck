"""
Lite-Deck Backend - FastAPI server with WebSocket support
"""
import json
import os
import logging
from pathlib import Path
from typing import List, Dict, Any
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn

from audio_player import AudioPlayer
from keyboard_handler import KeyboardHandler

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(title="Lite-Deck Backend", version="1.0.0")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global instances
audio_player: AudioPlayer = None
keyboard_handler: KeyboardHandler = None
config: Dict[str, Any] = {}
connected_clients: List[WebSocket] = []


def load_config() -> Dict[str, Any]:
    """Load configuration from config.json"""
    config_path = Path(__file__).parent.parent / "config.json"
    
    if not config_path.exists():
        logger.error(f"Config file not found: {config_path}")
        return {"buttons": []}
    
    with open(config_path, 'r') as f:
        return json.load(f)


def handle_key_press(key_name: str) -> None:
    """
    Handle keyboard button press - find matching button and play sound
    
    Args:
        key_name: The key identifier (e.g., 'num_0', 'f5')
    """
    # Find button with matching key
    for button in config.get("buttons", []):
        if button.get("key") == key_name and button.get("sound"):
            logger.info(f"Playing sound for key: {key_name}")
            audio_player.play_sound(button["sound"])
            break


def handle_button_press(button_id: int) -> None:
    """
    Handle button press from Flutter app - play assigned sound
    
    Args:
        button_id: The button ID from config
    """
    # Find button with matching ID
    for button in config.get("buttons", []):
        if button.get("id") == button_id and button.get("sound"):
            logger.info(f"Playing sound for button ID: {button_id}")
            audio_player.play_sound(button["sound"])
            break


@app.on_event("startup")
async def startup_event():
    """Initialize components on startup"""
    global audio_player, keyboard_handler, config
    
    # Load configuration
    config = load_config()
    logger.info(f"Loaded config with {len(config.get('buttons', []))} buttons")
    
    # Get audio device from config
    audio_device = config.get("backend", {}).get("audio_device", "Default")
    logger.info(f"Audio output device: {audio_device}")
    
    # Initialize audio player with device selection
    audio_player = AudioPlayer(base_path=str(Path(__file__).parent.parent), audio_device=audio_device)
    logger.info("Audio player initialized")
    
    # Initialize and start keyboard handler
    keyboard_handler = KeyboardHandler(key_callback=handle_key_press)
    keyboard_handler.start()
    logger.info("Keyboard handler initialized and started")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    if keyboard_handler:
        keyboard_handler.stop()
    logger.info("Backend shut down")


@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Lite-Deck Backend Running", "version": "1.0.0"}


@app.get("/config")
async def get_config():
    """Get current configuration"""
    return JSONResponse(content=config)


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint for Flutter app communication
    """
    await websocket.accept()
    connected_clients.append(websocket)
    logger.info(f"Client connected. Total clients: {len(connected_clients)}")
    
    try:
        # Send initial config
        await websocket.send_json({"type": "config", "data": config})
        
        # Listen for messages
        while True:
            data = await websocket.receive_json()
            
            if data.get("type") == "button_press":
                button_id = data.get("button_id")
                logger.info(f"📱 Received button press from app: button_id={button_id}")
                if button_id:
                    handle_button_press(button_id)
                    
    except WebSocketDisconnect:
        connected_clients.remove(websocket)
        logger.info(f"Client disconnected. Total clients: {len(connected_clients)}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        if websocket in connected_clients:
            connected_clients.remove(websocket)


if __name__ == "__main__":
    import sys
    
    # Check for headless mode
    headless = "--headless" in sys.argv or config.get("backend", {}).get("headless", False)
    
    if headless:
        logger.setLevel(logging.WARNING)
    
    host = config.get("backend", {}).get("host", "0.0.0.0")
    port = config.get("backend", {}).get("port", 8000)
    
    logger.info(f"Starting Lite-Deck backend on {host}:{port}")
    logger.info(f"Headless mode: {headless}")
    
    uvicorn.run(app, host=host, port=port, log_level="warning" if headless else "info")
