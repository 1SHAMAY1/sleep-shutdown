#!/bin/bash
# =====================================================================
# install_linux.sh
# Installer + auto-updater for "Sleep Shutdown" on Linux.
# Downloads the latest release from your GitHub repo, installs it to
# ~/.local/share/sleep-shutdown, adds a .desktop launcher, and checks
# GitHub for updates each time it runs.
#
# >>> EDIT THIS LINE with your actual GitHub repo <<<
# =====================================================================
REPO="1SHAMAY1/sleep-shutdown"          # <-- change to "youruser/yourrepo"
ASSET_NAME="sleep-shutdown-linux.tar.gz"
APP_NAME="Sleep Shutdown"
INSTALL_DIR="$HOME/.local/share/sleep-shutdown"
VERSION_FILE="$INSTALL_DIR/version.txt"
BIN_PATH="$INSTALL_DIR/sleep-shutdown"
DESKTOP_FILE="$HOME/.local/share/applications/sleep-shutdown.desktop"

mkdir -p "$INSTALL_DIR"

echo "Checking for latest version of $APP_NAME..."

API_URL="https://api.github.com/repos/$REPO/releases/latest"
RELEASE_JSON=$(curl -s -H "User-Agent: SleepShutdownUpdater" "$API_URL")

LATEST_VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url" | grep "$ASSET_NAME" | sed -E 's/.*"browser_download_url": *"([^"]+)".*/\1/')

CURRENT_VERSION=""
if [ -f "$VERSION_FILE" ]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
fi

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Could not reach GitHub or find asset '$ASSET_NAME' in latest release."
  if [ -f "$BIN_PATH" ]; then
    echo "Launching existing installed version instead."
  else
    echo "No existing installation found. Cannot continue."
    exit 1
  fi
else
  if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ] && [ -f "$BIN_PATH" ]; then
    echo "$APP_NAME is already up to date ($LATEST_VERSION)."
  else
    echo "Installing $APP_NAME $LATEST_VERSION..."
    TMP_TAR="/tmp/sleep-shutdown-linux.tar.gz"
    curl -L -o "$TMP_TAR" "$DOWNLOAD_URL"

    tar -xzf "$TMP_TAR" -C "$INSTALL_DIR"
    chmod +x "$BIN_PATH"
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "Installed $APP_NAME $LATEST_VERSION to $INSTALL_DIR"
  fi
fi

# --- Create a desktop launcher (first run only) ---
mkdir -p "$(dirname "$DESKTOP_FILE")"
if [ ! -f "$DESKTOP_FILE" ]; then
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Comment=Closes all apps and shuts down the PC
Exec=$INSTALL_DIR/install_linux.sh
Icon=system-shutdown
Terminal=true
Categories=Utility;
EOF
  chmod +x "$DESKTOP_FILE"
  echo "Desktop launcher added (search '$APP_NAME' in your app menu)."
fi

echo "Launching $APP_NAME..."
"$BIN_PATH"
