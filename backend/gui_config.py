"""
SounDeck GUI Configuration Tool
Minimal Tkinter app for configuring buttons, keys, and sounds
"""
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import json
import os
import subprocess
import webbrowser
import socket
from pathlib import Path

try:
    import qrcode
    from PIL import Image, ImageTk
    QR_AVAILABLE = True
except ImportError:
    QR_AVAILABLE = False

class SounDeckGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("SounDeck Configuration")
        self.root.geometry("800x600")
        self.root.configure(bg='#1a1a1a')
        
        self.config_path = Path(__file__).parent.parent / "config.json"
        self.backend_process = None
        self.config = self.load_config()
        
        self.setup_ui()
        
    def load_config(self):
        """Load configuration from config.json"""
        if self.config_path.exists():
            with open(self.config_path, 'r') as f:
                return json.load(f)
        return {"buttons": []}
    
    def save_config(self):
        """Save configuration to config.json"""
        try:
            with open(self.config_path, 'w') as f:
                json.dump(self.config, f, indent=2)
            messagebox.showinfo("Success", "Configuration saved!")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save: {e}")
    
    def setup_ui(self):
        """Setup the user interface"""
        # Header
        header = tk.Frame(self.root, bg='#1a1a1a')
        header.pack(fill=tk.X, padx=10, pady=10)
        
        title = tk.Label(header, text="SounDeck Configuration", 
                        font=('Arial', 18, 'bold'),
                        bg='#1a1a1a', fg='#39FF14')
        title.pack(side=tk.LEFT)
        
        # Control buttons
        btn_frame = tk.Frame(header, bg='#1a1a1a')
        btn_frame.pack(side=tk.RIGHT)
        
        save_btn = tk.Button(btn_frame, text="💾 Save", 
                           command=self.save_config,
                           bg='#39FF14', fg='black',
                           font=('Arial', 10, 'bold'),
                           relief=tk.FLAT, padx=15, pady=5)
        save_btn.pack(side=tk.LEFT, padx=5)
        
        backend_btn = tk.Button(btn_frame, text="▶ Start Backend", 
                              command=self.toggle_backend,
                              bg='#333', fg='white',
                              font=('Arial', 10),
                              relief=tk.FLAT, padx=15, pady=5)
        backend_btn.pack(side=tk.LEFT, padx=5)
        self.backend_btn = backend_btn
        
        # Connection info panel with QR code
        info_frame = tk.Frame(self.root, bg='#2a2a2a', relief=tk.RAISED, borderwidth=1)
        info_frame.pack(fill=tk.X, padx=10, pady=(0, 10))
        
        # Left side - Connection info
        info_left = tk.Frame(info_frame, bg='#2a2a2a')
        info_left.pack(side=tk.LEFT, padx=10, pady=10)
        
        tk.Label(info_left, text="📱 Connect Your Phone", 
                font=('Arial', 12, 'bold'),
                bg='#2a2a2a', fg='#39FF14').pack(anchor='w')
        
        ip_text = self.get_local_ip()
        tk.Label(info_left, text=f"IP: {ip_text}", 
                font=('Arial', 10),
                bg='#2a2a2a', fg='white').pack(anchor='w', pady=(5, 0))
        
        tk.Label(info_left, text="Port: 8000", 
                font=('Arial', 10),
                bg='#2a2a2a', fg='white').pack(anchor='w')
        
        # Audio device selector
        tk.Label(info_left, text="🔊 Audio Output:", 
                font=('Arial', 10, 'bold'),
                bg='#2a2a2a', fg='#39FF14').pack(anchor='w', pady=(10, 5))
        
        from audio_player import AudioPlayer
        devices = AudioPlayer.get_audio_devices()
        
        self.audio_device_var = tk.StringVar(value=self.config.get("backend", {}).get("audio_device", "Default"))
        device_dropdown = ttk.Combobox(info_left, textvariable=self.audio_device_var,
                                      values=devices, state='readonly', width=30)
        device_dropdown.pack(anchor='w')
        device_dropdown.bind('<<ComboboxSelected>>', self.on_audio_device_changed)
        
        # Browser links
        links_frame = tk.Frame(info_frame, bg='#2a2a2a')
        links_frame.pack(side=tk.LEFT, padx=20, pady=10)
        
        tk.Label(links_frame, text="🌐 Free Sound Sites", 
                font=('Arial', 12, 'bold'),
                bg='#2a2a2a', fg='#39FF14').pack(anchor='w')
        
        sound_sites = [
            ("Voicy", "https://www.voicy.network"),
            ("MyInstants", "https://www.myinstants.com"),
            ("Freesound", "https://freesound.org"),
        ]
        
        for name, url in sound_sites:
            link_btn = tk.Button(links_frame, text=f"🔗 {name}",
                               command=lambda u=url: webbrowser.open(u),
                               bg='#3a3a3a', fg='#39FF14',
                               font=('Arial', 9),
                               relief=tk.FLAT, padx=10, pady=2,
                               cursor='hand2')
            link_btn.pack(anchor='w', pady=2)
        
        # Right side - QR Code
        if QR_AVAILABLE:
            qr_frame = tk.Frame(info_frame, bg='#2a2a2a')
            qr_frame.pack(side=tk.RIGHT, padx=10, pady=10)
            
            tk.Label(qr_frame, text="Scan to Connect", 
                    font=('Arial', 9),
                    bg='#2a2a2a', fg='#888').pack()
            
            self.qr_label = tk.Label(qr_frame, bg='#2a2a2a')
            self.qr_label.pack()
            self.generate_qr_code(ip_text)
        
        # Scrollable frame for buttons
        container = tk.Frame(self.root, bg='#1a1a1a')
        container.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        canvas = tk.Canvas(container, bg='#1a1a1a', highlightthickness=0)
        scrollbar = tk.Scrollbar(container, orient="vertical", command=canvas.yview)
        scrollable_frame = tk.Frame(canvas, bg='#1a1a1a')
        
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        # Create button grid (4 columns x 6 rows = 24 buttons)
        for i, button_config in enumerate(self.config.get("buttons", [])):
            self.create_button_widget(scrollable_frame, button_config, i)
    
    def create_button_widget(self, parent, button_config, index):
        """Create a widget for each button configuration"""
        frame = tk.Frame(parent, bg='#2a2a2a', relief=tk.RAISED, borderwidth=2)
        frame.grid(row=index//4, column=index%4, padx=5, pady=5, sticky='nsew')
        
        # Configure grid weights
        parent.grid_columnconfigure(index%4, weight=1)
        
        # Button ID
        id_label = tk.Label(frame, text=f"Button {button_config.get('id', index)}",
                          font=('Arial', 10, 'bold'),
                          bg='#2a2a2a', fg='#39FF14')
        id_label.pack(pady=(5, 0))
        
        # Name
        name_var = tk.StringVar(value=button_config.get('name', ''))
        name_entry = tk.Entry(frame, textvariable=name_var,
                            bg='#3a3a3a', fg='white',
                            font=('Arial', 9),
                            relief=tk.FLAT)
        name_entry.pack(fill=tk.X, padx=5, pady=2)
        name_var.trace('w', lambda *args: self.update_button_name(button_config, name_var.get()))
        
        # Key binding
        key_frame = tk.Frame(frame, bg='#2a2a2a')
        key_frame.pack(fill=tk.X, padx=5, pady=2)
        
        tk.Label(key_frame, text="Key:", bg='#2a2a2a', fg='#888',
                font=('Arial', 8)).pack(side=tk.LEFT)
        
        key_var = tk.StringVar(value=button_config.get('key', ''))
        key_entry = tk.Entry(key_frame, textvariable=key_var,
                           bg='#3a3a3a', fg='white',
                           font=('Arial', 9),
                           relief=tk.FLAT, width=10)
        key_entry.pack(side=tk.LEFT, padx=5)
        key_var.trace('w', lambda *args: self.update_button_key(button_config, key_var.get()))
        
        # Sound file
        sound_frame = tk.Frame(frame, bg='#2a2a2a')
        sound_frame.pack(fill=tk.X, padx=5, pady=2)
        
        current_sound = button_config.get('sound', '')
        sound_text = os.path.basename(current_sound) if current_sound else "No sound"
        sound_label = tk.Label(sound_frame, text=sound_text,
                             bg='#3a3a3a', fg='white',
                             font=('Arial', 8),
                             anchor='w')
        sound_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))
        
        sound_btn = tk.Button(sound_frame, text="🔊",
                            command=lambda: self.select_sound(button_config, sound_label),
                            bg='#39FF14', fg='black',
                            font=('Arial', 10),
                            relief=tk.FLAT, width=3)
        sound_btn.pack(side=tk.RIGHT)
    
    def update_button_name(self, button_config, new_name):
        """Update button name"""
        button_config['name'] = new_name
    
    def update_button_key(self, button_config, new_key):
        """Update button key binding"""
        button_config['key'] = new_key
    
    def select_sound(self, button_config, sound_label):
        """Open file dialog to select sound file"""
        filetypes = (
            ('Audio files', '*.mp3 *.wav *.ogg'),
            ('All files', '*.*')
        )
        
        initial_dir = Path(__file__).parent.parent / "backend" / "sounds"
        filename = filedialog.askopenfilename(
            title='Select sound file',
            initialdir=initial_dir,
            filetypes=filetypes
        )
        
        if filename:
            # Make path relative to project root
            try:
                rel_path = os.path.relpath(filename, Path(__file__).parent.parent)
                button_config['sound'] = rel_path
                sound_label.config(text=os.path.basename(filename))
            except:
                button_config['sound'] = filename
                sound_label.config(text=os.path.basename(filename))
    
    def toggle_backend(self):
        """Start or stop the backend server"""
        if self.backend_process is None:
            try:
                backend_path = Path(__file__).parent.parent / "backend" / "main.py"
                self.backend_process = subprocess.Popen(
                    ['python', str(backend_path)],
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.backend_btn.config(text="⏹ Stop Backend", bg='#ff3333')
                messagebox.showinfo("Backend", "Backend server started!")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to start backend: {e}")
        else:
            self.backend_process.terminate()
            self.backend_process = None
            self.backend_btn.config(text="▶ Start Backend", bg='#333')
            messagebox.showinfo("Backend", "Backend server stopped!")
    
    
    def get_local_ip(self):
        """Get local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "127.0.0.1"
    
    def generate_qr_code(self, ip):
        """Generate QR code for connection"""
        if not QR_AVAILABLE:
            return
        
        try:
            # Create connection info as JSON
            connection_data = json.dumps({
                "ip": ip,
                "port": 8000,
                "app": "SounDeck"
            })
            
            qr = qrcode.QRCode(version=1, box_size=3, border=2)
            qr.add_data(connection_data)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="#39FF14", back_color="#1a1a1a")
            img = img.resize((120, 120))
            
            photo = ImageTk.PhotoImage(img)
            self.qr_label.config(image=photo)
            self.qr_label.image = photo
        except Exception as e:
            print(f"QR code generation failed: {e}")
    
    def on_audio_device_changed(self, event=None):
        """Handle audio device selection change"""
        device = self.audio_device_var.get()
        if "backend" not in self.config:
            self.config["backend"] = {}
        self.config["backend"]["audio_device"] = device
        self.save_config()
        messagebox.showinfo("Audio Device", f"Audio output set to: {device}\n\nRestart backend for changes to take effect!")
    
    def on_closing(self):
        """Handle window close event"""
        if self.backend_process:
            self.backend_process.terminate()
        self.root.destroy()

def main():
    root = tk.Tk()
    app = SounDeckGUI(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()

if __name__ == "__main__":
    main()
