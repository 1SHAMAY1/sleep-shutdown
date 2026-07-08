#!/usr/bin/env python3
"""
Sleep Shutdown
Closes all running user applications, then shuts down the computer.
Works on Windows, macOS, and Linux.
"""

import sys
import time
import platform
import subprocess

try:
    import psutil
except ImportError:
    print("Missing dependency 'psutil'. Install with: pip install psutil")
    sys.exit(1)

OS_NAME = platform.system()  # "Windows", "Darwin", "Linux"

# Process names to never touch, per OS
EXCLUDE = {
    "Windows": {
        "explorer.exe", "svchost.exe", "system", "idle", "registry", "csrss.exe",
        "wininit.exe", "services.exe", "lsass.exe", "smss.exe", "winlogon.exe",
        "dwm.exe", "runtimebroker.exe", "shellexperiencehost.exe", "searchapp.exe",
        "searchhost.exe", "startmenuexperiencehost.exe", "textinputhost.exe",
        "ctfmon.exe", "conhost.exe", "powershell.exe", "pwsh.exe", "cmd.exe",
        "wmiprvse.exe", "spoolsv.exe", "dllhost.exe", "taskhostw.exe", "sihost.exe",
        "securityhealthservice.exe", "securityhealthsystray.exe",
        "applicationframehost.exe", "lockapp.exe", "backgroundtaskhost.exe",
        "audiodg.exe", "dashost.exe", "python.exe", "pythonw.exe",
        "sleep-shutdown.exe",
    },
    "Darwin": {
        "finder", "dock", "systemuiserver", "windowserver", "loginwindow",
        "coreservicesd", "launchd", "cfprefsd", "sleep-shutdown",
    },
    "Linux": {
        "gnome-shell", "plasmashell", "xorg", "wayland", "systemd", "dbus-daemon",
        "pulseaudio", "pipewire", "networkmanager", "sleep-shutdown",
    },
}


def get_target_processes():
    """Return list of running user-facing processes to close."""
    exclude = EXCLUDE.get(OS_NAME, set())
    targets = []
    for proc in psutil.process_iter(["pid", "name"]):
        try:
            name = (proc.info["name"] or "").lower()
            if not name or name in exclude:
                continue
            targets.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return targets


def close_apps():
    procs = get_target_processes()
    if not procs:
        print("No user apps found running.")
        return

    print(f"Closing {len(procs)} app(s):")
    for p in procs:
        try:
            print(f" - {p.info['name']} (pid {p.pid})")
            p.terminate()  # graceful request to quit
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    gone, alive = psutil.wait_procs(procs, timeout=5)

    for p in alive:
        try:
            print(f"Force-closing {p.info['name']} (pid {p.pid})")
            p.kill()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass


def shutdown():
    print("Shutting down in 15 seconds... Press CTRL+C now to cancel.")
    try:
        time.sleep(15)
    except KeyboardInterrupt:
        print("Shutdown cancelled.")
        return

    if OS_NAME == "Windows":
        subprocess.run(["shutdown", "/s", "/t", "0"])
    elif OS_NAME == "Darwin":
        subprocess.run(["osascript", "-e", 'tell app "System Events" to shut down'])
    elif OS_NAME == "Linux":
        subprocess.run(["shutdown", "-h", "now"])
    else:
        print(f"Unsupported OS: {OS_NAME}")


def main():
    print(f"Sleep Shutdown starting on {OS_NAME}...")
    close_apps()
    shutdown()


if __name__ == "__main__":
    main()
