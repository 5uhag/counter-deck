"""
Keyboard handler using pynput for cross-platform keyboard listening
"""
from pynput import keyboard
from typing import Dict, Callable, Optional
import logging

logger = logging.getLogger(__name__)


# Mapping of pynput keys to config key names
KEY_MAPPINGS = {
    keyboard.KeyCode.from_vk(96): "num_0",   # Numpad 0
    keyboard.KeyCode.from_vk(97): "num_1",   # Numpad 1
    keyboard.KeyCode.from_vk(98): "num_2",   # Numpad 2
    keyboard.KeyCode.from_vk(99): "num_3",   # Numpad 3
    keyboard.KeyCode.from_vk(100): "num_4",  # Numpad 4
    keyboard.KeyCode.from_vk(101): "num_5",  # Numpad 5
    keyboard.KeyCode.from_vk(102): "num_6",  # Numpad 6
    keyboard.KeyCode.from_vk(103): "num_7",  # Numpad 7
    keyboard.KeyCode.from_vk(104): "num_8",  # Numpad 8
    keyboard.KeyCode.from_vk(105): "num_9",  # Numpad 9
    keyboard.KeyCode.from_vk(107): "num_add",      # Numpad +
    keyboard.KeyCode.from_vk(109): "num_subtract", # Numpad -
    keyboard.KeyCode.from_vk(106): "num_multiply", # Numpad *
    keyboard.KeyCode.from_vk(111): "num_divide",   # Numpad /
    keyboard.KeyCode.from_vk(110): "num_decimal",  # Numpad .
    keyboard.Key.f5: "f5",
    keyboard.Key.f6: "f6",
    keyboard.Key.f7: "f7",
    keyboard.Key.f8: "f8",
}


class KeyboardHandler:
    def __init__(self, key_callback: Callable[[str], None]):
        """
        Initialize keyboard handler
        
        Args:
            key_callback: Function to call when a mapped key is pressed
        """
        self.key_callback = key_callback
        self.listener: Optional[keyboard.Listener] = None
        
    def start(self) -> None:
        """Start listening to keyboard events"""
        self.listener = keyboard.Listener(on_press=self._on_press)
        self.listener.start()
        logger.info("Keyboard listener started")
        
    def stop(self) -> None:
        """Stop listening to keyboard events"""
        if self.listener:
            self.listener.stop()
            logger.info("Keyboard listener stopped")
    
    def _on_press(self, key) -> None:
        """
        Internal callback for key press events
        
        Args:
            key: The key that was pressed
        """
        # Check if this key is in our mappings
        key_name = KEY_MAPPINGS.get(key)
        
        if key_name:
            logger.debug(f"Key pressed: {key_name}")
            self.key_callback(key_name)
