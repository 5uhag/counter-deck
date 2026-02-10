"""
Kill all SounDeck related processes
Emergency cleanup script - only kills processes from counter-deck folder
"""
import psutil
import sys
import os
from pathlib import Path

def kill_soundeck_processes():
    """Find and kill all SounDeck-related processes from counter-deck folder"""
    killed_count = 0
    
    # Get the counter-deck project directory
    project_dir = Path(__file__).parent.parent.resolve()
    project_dir_str = str(project_dir).lower()
    
    print(f"[*] Searching for SounDeck processes in: {project_dir}")
    
    for proc in psutil.process_iter(['pid', 'name', 'exe', 'cmdline']):
        try:
            proc_info = proc.info
            
            # Get command line and exe path safely
            cmdline = proc_info.get('cmdline', [])
            exe = proc_info.get('exe', '')
            
            if not cmdline:
                continue
            
            # Convert to string safely (handle encoding issues)
            cmdline_str = ' '.join(str(arg) for arg in cmdline if arg).lower()
            exe_str = str(exe).lower() if exe else ''
            
            # Check if this process is from counter-deck folder
            is_from_project = project_dir_str in cmdline_str or project_dir_str in exe_str
            
            # Check if it's a SounDeck process
            is_soundeck = any(keyword in cmdline_str for keyword in 
                            ['soundeck', 'gui_config.py', 'main.py', 'uvicorn'])
            
            if is_from_project and is_soundeck:
                try:
                    proc_name = proc_info.get('name', 'Unknown')
                    print(f"    [!] Killing: {proc_name} (PID: {proc_info['pid']})")
                    proc.kill()
                    proc.wait(timeout=3)
                    killed_count += 1
                except Exception as e:
                    print(f"    [!] Failed to kill PID {proc_info['pid']}: {e}")
                
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.TimeoutExpired):
            pass
        except Exception:
            # Silently skip encoding errors and other issues
            pass
    
    if killed_count > 0:
        print(f"\n[+] Successfully killed {killed_count} SounDeck process(es)")
    else:
        print("\n[*] No SounDeck processes found")
    
    return killed_count

if __name__ == "__main__":
    try:
        killed = kill_soundeck_processes()
        sys.exit(0)
    except Exception as e:
        print(f"\n[-] Error: {e}")
        sys.exit(1)
