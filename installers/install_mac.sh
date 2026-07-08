#!/bin/bash
# =====================================================================
# install_mac.sh
# Installer + auto-updater for "Sleep Shutdown" on macOS.
# Downloads the latest release from your GitHub repo, installs it to
# /Applications, and checks GitHub for updates each time it runs.
#
# >>> EDIT THIS LINE with your actual GitHub repo <<<
# =====================================================================
REPO="1SHAMAY1/sleep-shutdown"          # <-- change to "youruser/yourrepo"
ASSET_NAME="sleep-shutdown-mac.zip"
APP_NAME="Sleep Shutdown"
INSTALL_DIR="$HOME/Library/Application Support/SleepShutdown"
VERSION_FILE="$INSTALL_DIR/version.txt"
APP_PATH="/Applications/$APP_NAME.app"

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
  if [ -d "$APP_PATH" ]; then
    echo "Launching existing installed version instead."
  else
    echo "No existing installation found. Cannot continue."
    exit 1
  fi
else
  if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ] && [ -d "$APP_PATH" ]; then
    echo "$APP_NAME is already up to date ($LATEST_VERSION)."
  else
    echo "Installing $APP_NAME $LATEST_VERSION..."
    TMP_ZIP="/tmp/sleep-shutdown-mac.zip"
    curl -L -o "$TMP_ZIP" "$DOWNLOAD_URL"

    rm -rf "$APP_PATH"
    unzip -oq "$TMP_ZIP" -d /Applications/
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "Installed $APP_NAME $LATEST_VERSION to /Applications"
  fi
fi

echo "Launching $APP_NAME..."
open "$APP_PATH"
