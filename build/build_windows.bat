@echo off
REM Builds sleep-shutdown-windows.exe from app/main.py using PyInstaller.
REM Run this ON Windows (PyInstaller builds are not cross-platform).

pip install -r ..\app\requirements.txt pyinstaller
pyinstaller --onefile --console --name sleep-shutdown-windows ..\app\main.py

echo.
echo Done. Find your exe in dist\sleep-shutdown-windows.exe
echo Upload that file to your GitHub Release as "sleep-shutdown-windows.exe"
pause
