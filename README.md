# Sleep Shutdown

A lightweight, cross-platform utility that closes all running user applications and shuts down your computer. One click/run, no more manually closing 15 windows before bed.

## Features

- **Graceful Application Closure**: Iterates through all running user processes with visible windows and requests them to close gracefully. If any process refuses to exit, it force-closes it after a 5-second grace period.
- **System Safeguards**: Automatically ignores system-critical processes (like Explorer, Finder, systemd, etc.) to prevent OS instability.
- **15-Second Cancellation Window**: Initiates a 15-second countdown allowing you to press `CTRL+C` to abort the shutdown process if triggered accidentally.
- **Cross-Platform Auto-Updates**: Installer scripts check GitHub Releases for updates every time they launch, downloading newer versions automatically.

---

## Directory Layout

```
sleep-shutdown/
├── app/                  # The Python application source
│   ├── main.py           # Core logic for process control and shutdown
│   └── requirements.txt  # Dependencies (psutil)
├── build/                # Local packaging scripts (PyInstaller wrappers)
│   ├── build_windows.bat
│   ├── build_mac.sh
│   └── build_linux.sh
└── installers/           # Bootstrappers and update check scripts
    ├── install_windows.ps1
    ├── install_mac.sh
    └── install_linux.sh
```

---

## Installation & Usage

To download and run the latest version, run the installer script corresponding to your operating system:

### Windows
Run this command in PowerShell:
```powershell
irm https://raw.githubusercontent.com/1SHAMAY1/sleep-shutdown/main/installers/install_windows.ps1 | iex
```
*Creates a Desktop shortcut to run the tool.*

### macOS
Run this command in your Terminal:
```bash
curl -sSL https://raw.githubusercontent.com/1SHAMAY1/sleep-shutdown/main/installers/install_mac.sh | bash
```

### Linux
Run this command in your Terminal:
```bash
curl -sSL https://raw.githubusercontent.com/1SHAMAY1/sleep-shutdown/main/installers/install_linux.sh | bash
```

---

## Automated Builds & Releases

This repository uses **GitHub Actions** to automatically build standalone binaries on every release. 

To ship updates to your users:
1. Rebuild and publish by pushing a new version tag (e.g., `v1.0.1`):
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
2. The GitHub Actions pipeline will compile:
   - `sleep-shutdown-windows.exe` (Windows console executable)
   - `sleep-shutdown-mac.zip` (macOS GUI app wrapper)
   - `sleep-shutdown-linux.tar.gz` (Linux standalone binary)
3. It creates a GitHub Release and uploads the binaries + installer scripts as assets.
4. Next time users run their local shortcut/launcher, the script checks GitHub, downloads the update, and starts the new version.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
