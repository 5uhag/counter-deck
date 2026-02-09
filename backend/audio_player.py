"""
Audio playback handler with device selection support
"""
import os
import pygame
from pathlib import Path
from threading import Thread

class AudioPlayer:
    def __init__(self, base_path: str = "", audio_device: str = None):
        """
        Initialize audio player
        
        Args:
            base_path: Base path for resolving sound file paths
            audio_device: Specific audio device name (optional)
        """
        self.base_path = Path(base_path)
        self.audio_device = audio_device
        
        # Initialize pygame mixer
        pygame.mixer.init()
    
    def set_audio_device(self, device_name: str):
        """Set the audio output device"""
        self.audio_device = device_name
    
    @staticmethod
    def get_audio_devices():
        """Get list of available audio output devices"""
        return [
            "Default",
            "VB-Audio Virtual Cable",
            "CABLE Input (VB-Audio Virtual Cable)",
            "Speakers",
        ]
    
    def play_sound(self, sound_path: str):
        """
        Play a sound file in a non-blocking way
        
        Args:
            sound_path: Path to sound file (relative or absolute)
        """
        def _play():
            try:
                # Resolve path
                if os.path.isabs(sound_path):
                    full_path = Path(sound_path)
                else:
                    full_path = self.base_path / sound_path
                
                # Check if file exists
                if not full_path.exists():
                    print(f"Sound file not found: {full_path}")
                    return
                
                # Load and play sound
                pygame.mixer.music.load(str(full_path))
                pygame.mixer.music.play()
                
                # Wait for sound to finish
                while pygame.mixer.music.get_busy():
                    pygame.time.Clock().tick(10)
                    
            except Exception as e:
                print(f"Error playing sound: {e}")
        
        # Play in separate thread to avoid blocking
        thread = Thread(target=_play, daemon=True)
        thread.start()
