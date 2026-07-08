# =====================================================================
# install_windows.ps1
# Installer + auto-updater for "Sleep Shutdown".
# Downloads the latest release from your GitHub repo, installs it,
# creates Start Menu / Desktop shortcuts, and checks GitHub for
# updates every time it's launched (via the shortcut).
#
# >>> EDIT THIS LINE with your actual GitHub repo <<<
# =====================================================================
$Repo = "1SHAMAY1/sleep-shutdown"     # <-- change to "youruser/yourrepo"
$AssetName = "sleep-shutdown-windows.exe"
$AppName = "Sleep Shutdown"
$InstallDir = "$env:LOCALAPPDATA\SleepShutdown"
$ExePath = "$InstallDir\$AssetName"
$VersionFile = "$InstallDir\version.txt"

function Get-LatestRelease {
    $api = "https://api.github.com/repos/$Repo/releases/latest"
    return Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = "SleepShutdownUpdater" }
}

Write-Host "Checking for latest version of $AppName..."

try {
    $release = Get-LatestRelease
    $latestVersion = $release.tag_name
    $asset = $release.assets | Where-Object { $_.name -eq $AssetName }

    if (-not $asset) {
        Write-Host "ERROR: No asset named '$AssetName' found in the latest release."
        Write-Host "Check that your GitHub release has an asset with this exact name."
        pause
        exit 1
    }

    $currentVersion = if (Test-Path $VersionFile) { Get-Content $VersionFile } else { "" }

    if ($currentVersion -eq $latestVersion -and (Test-Path $ExePath)) {
        Write-Host "$AppName is already up to date ($latestVersion)."
    } else {
        Write-Host "Installing $AppName $latestVersion..."
        if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir | Out-Null }

        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $ExePath
        Set-Content -Path $VersionFile -Value $latestVersion

        Write-Host "Installed $AppName $latestVersion to $InstallDir"
    }
} catch {
    Write-Host "Could not check for updates (no internet or repo not found)."
    if (-not (Test-Path $ExePath)) {
        Write-Host "No existing installation found either. Cannot continue."
        pause
        exit 1
    }
    Write-Host "Launching existing installed version instead."
}

# --- Create Desktop + Start Menu shortcuts (first run only) ---
$desktopShortcut = "$env:USERPROFILE\Desktop\$AppName.lnk"
if (-not (Test-Path $desktopShortcut)) {
    $ws = New-Object -ComObject WScript.Shell
    $s = $ws.CreateShortcut($desktopShortcut)
    $s.TargetPath = "powershell.exe"
    $s.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $s.IconLocation = "shell32.dll,27"
    $s.Description = "Closes all apps and shuts down the PC"
    $s.Save()
    Write-Host "Desktop shortcut created."
}

# --- Launch the app ---
Write-Host "Launching $AppName..."
Start-Process -FilePath $ExePath
