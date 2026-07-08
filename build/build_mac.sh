#!/bin/bash
# Builds Sleep Shutdown.app from app/main.py using PyInstaller.
# Run this ON macOS (PyInstaller builds are not cross-platform).

pip3 install -r ../app/requirements.txt pyinstaller
pyinstaller --onefile --windowed --name "Sleep Shutdown" ../app/main.py

echo ""
echo "Done. Find your app in dist/Sleep Shutdown.app"
echo "Zip it and upload as 'sleep-shutdown-mac.zip' to your GitHub Release:"
echo "  cd dist && zip -r sleep-shutdown-mac.zip 'Sleep Shutdown.app'"
