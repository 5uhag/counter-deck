"""
Lite-Deck Backend - FastAPI server with WebSocket support
"""
import json
import os
import logging
import secrets
import signal
import sys
from pathlib import Path
from typing import List, Dict, Any
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import uvicorn

from audio_player import AudioPlayer
from keyboard_handler import KeyboardHandler

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Rate limiting setup
limiter = Limiter(key_func=get_remote_address)

# Initialize FastAPI app
app = FastAPI(title="Lite-Deck Backend", version="1.0.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Add CORS middleware (must be done before app starts)
# Default to localhost only - will be updated during startup if config specifies
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global instances
audio_player: AudioPlayer = None
keyboard_handler: KeyboardHandler = None
config: Dict[str, Any] = {}
connected_clients: List[WebSocket] = []
API_KEY: str = ""



def load_config() -> Dict[str, Any]:
    """Load configuration from config.json"""
    config_path = Path(__file__).parent.parent / "config.json"
    
    if not config_path.exists():
        logger.error(f"Config file not found: {config_path}")
        return {"buttons": []}
    
    with open(config_path, 'r') as f:
        return json.load(f)


def save_config(config_data: Dict[str, Any]) -> None:
    """Save configuration to config.json"""
    config_path = Path(__file__).parent.parent / "config.json"
    with open(config_path, 'w') as f:
        json.dump(config_data, f, indent=2)
    logger.info("Configuration saved")


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
    global audio_player, keyboard_handler, config, API_KEY
    
    # Load configuration
    config = load_config()
    logger.info(f"Loaded config with {len(config.get('buttons', []))} buttons")
    
    # Generate or load API key
    if "backend" not in config:
        config["backend"] = {}
    
    if not config["backend"].get("api_key"):
        API_KEY = secrets.token_urlsafe(32)
        config["backend"]["api_key"] = API_KEY
        save_config(config)
        logger.warning(f"🔐 Generated new API key: {API_KEY[:8]}...")
    else:
        API_KEY = config["backend"]["api_key"]
        logger.info(f"🔐 Loaded existing API key: {API_KEY[:8]}...")
    
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
    logger.info("✓ Backend startup complete")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    if keyboard_handler:
        keyboard_handler.stop()
    logger.info("Backend shut down cleanly")


async def verify_api_key(request: Request) -> bool:
    """Verify API key from request headers or query params"""
    # Check Authorization header
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        token = auth_header[7:]
        if token == API_KEY:
            return True
    
    # Check query parameter (for WebSocket connections)
    api_key_param = request.query_params.get("api_key", "")
    if api_key_param == API_KEY:
        return True
    
    # Log unauthorized access attempt
    client_ip = request.client.host if request.client else "unknown"
    logger.warning(f"⚠️ Unauthorized access attempt from {client_ip}")
    return False


@app.middleware("http")
async def authentication_middleware(request: Request, call_next):
    """Authentication middleware for all HTTP requests"""
    # Allow health check without auth
    if request.url.path in ["/health", "/"]:
        return await call_next(request)
    
    # Verify API key
    if not await verify_api_key(request):
        return JSONResponse(
            status_code=401,
            content={"error": "Unauthorized", "message": "Invalid or missing API key"}
        )
    
    return await call_next(request)



@app.get("/")
@limiter.limit("30/minute")
async def root(request: Request):
    """Root endpoint"""
    return {"message": "Lite-Deck Backend Running", "version": "1.0.0", "auth": "required"}


@app.get("/health")
async def health():
    """Health check endpoint (no auth required)"""
    return {"status": "healthy", "version": "1.0.0"}


@app.get("/config")
@limiter.limit("10/minute")
async def get_config(request: Request):
    """Get current configuration (requires auth)"""
    return JSONResponse(content=config)



@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint for Flutter app communication (requires API key)
    """
    # Check API key from query parameter
    api_key_param = websocket.query_params.get("api_key", "")
    if api_key_param != API_KEY:
        client_host = websocket.client.host if websocket.client else "unknown"
        logger.warning(f"⚠️ Unauthorized WebSocket connection attempt from {client_host}")
        await websocket.close(code=1008, reason="Unauthorized")
        return
    
    await websocket.accept()
    connected_clients.append(websocket)
    logger.info(f"✅ Authenticated client connected. Total clients: {len(connected_clients)}")
    
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
