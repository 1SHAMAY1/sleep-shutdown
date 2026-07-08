#!/bin/bash
# Builds a sleep-shutdown Linux binary from app/main.py using PyInstaller.
# Run this ON Linux (PyInstaller builds are not cross-platform).

pip3 install -r ../app/requirements.txt pyinstaller
pyinstaller --onefile --console --name sleep-shutdown ../app/main.py

echo ""
echo "Done. Find your binary in dist/sleep-shutdown"
echo "Package it and upload as 'sleep-shutdown-linux.tar.gz' to your GitHub Release:"
echo "  cd dist && tar -czf sleep-shutdown-linux.tar.gz sleep-shutdown"
