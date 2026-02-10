"""
Kill all SounDeck related processes
Emergency cleanup script
"""
import psutil
import sys

def kill_soundeck_processes():
    """Find and kill all SounDeck-related processes"""
    killed_count = 0
    soundeck_keywords = ['soundeck', 'gui_config', 'main.py', 'uvicorn']
    
    print("🔍 Searching for SounDeck processes...")
    
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            # Get process info
            proc_info = proc.info
            cmdline = ' '.join(proc_info['cmdline']) if proc_info['cmdline'] else ''
            
            # Check if this is a SounDeck process
            is_soundeck = any(keyword.lower() in cmdline.lower() 
                            for keyword in soundeck_keywords)
            
            if is_soundeck:
                print(f"   Killing: {proc_info['name']} (PID: {proc_info['pid']})")
                proc.kill()
                proc.wait(timeout=3)
                killed_count += 1
                
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.TimeoutExpired):
            pass
    
    if killed_count > 0:
        print(f"\n✅ Killed {killed_count} SounDeck process(es)")
    else:
        print("\n✓ No SounDeck processes found")
    
    return killed_count

if __name__ == "__main__":
    try:
        killed = kill_soundeck_processes()
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)
