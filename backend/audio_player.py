"""
Non-blocking audio player using threading and playsound3
"""
import threading
import os
from playsound3 import playsound
from typing import Optional
import logging

logger = logging.getLogger(__name__)


class AudioPlayer:
    def __init__(self, base_path: str = "backend"):
        self.base_path = base_path
        
    def play_sound(self, sound_path: str) -> None:
        """
        Play a sound file in a non-blocking manner using threading
        
        Args:
            sound_path: Relative path to sound file from base_path
        """
        full_path = os.path.join(self.base_path, sound_path)
        
        if not os.path.exists(full_path):
            logger.error(f"Sound file not found: {full_path}")
            return
            
        # Play sound in separate thread to avoid blocking
        thread = threading.Thread(target=self._play_blocking, args=(full_path,), daemon=True)
        thread.start()
    
    def _play_blocking(self, file_path: str) -> None:
        """
        Internal method to play sound (runs in thread)
        
        Args:
            file_path: Full path to sound file
        """
        try:
            playsound(file_path, block=True)
        except Exception as e:
            logger.error(f"Error playing sound {file_path}: {e}")
