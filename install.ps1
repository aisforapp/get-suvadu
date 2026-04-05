# Suvadu installer for Windows — download tarball, extract, and configure for all detected MCP clients.
# Usage: irm https://suvadu.aisforapp.com/install.ps1 | iex
$ErrorActionPreference = "Stop"

$Repo = "aisforapp/get-suvadu"
$InstallDir = "$env:USERPROFILE\.local\lib\suvadu"
$BinDir = "$env:USERPROFILE\.local\bin"
$BinaryName = "suvadu.exe"

function Info($msg)  { Write-Host "==> " -ForegroundColor Green -NoNewline; Write-Host $msg -ForegroundColor White }
function Warn($msg)  { Write-Host "==> " -ForegroundColor Yellow -NoNewline; Write-Host $msg -ForegroundColor White }
function Error($msg) { Write-Host "==> " -ForegroundColor Red -NoNewline; Write-Host $msg -ForegroundColor White; exit 1 }

# --- Step 1: Detect architecture ---
$Arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "arm64" } else { "x86_64" }
$AssetName = "suvadu-windows-${Arch}.zip"
Info "Detected platform: windows-$Arch"

# --- Step 2: Download latest zip from GitHub Releases ---
Info "Downloading suvadu..."
$DownloadUrl = "https://github.com/$Repo/releases/latest/download/$AssetName"
$TmpDir = Join-Path $env:TEMP "suvadu-install-$(Get-Random)"
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null
$ZipPath = Join-Path $TmpDir $AssetName

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing
} catch {
    Error "Download failed. Check https://github.com/$Repo/releases"
}

# --- Step 3: Extract and install ---
Info "Installing..."
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}
$ParentDir = Split-Path $InstallDir -Parent
if (-not (Test-Path $ParentDir)) {
    New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
}
Expand-Archive -Path $ZipPath -DestinationPath $ParentDir -Force
Remove-Item -Recurse -Force $TmpDir

# --- Step 4: Create symlink in bin dir ---
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}
$SymlinkTarget = Join-Path $InstallDir $BinaryName
$SymlinkPath = Join-Path $BinDir $BinaryName

if (Test-Path $SymlinkPath) {
    Remove-Item -Force $SymlinkPath
}

# Try symbolic link first (requires admin or developer mode), fall back to copy
try {
    New-Item -ItemType SymbolicLink -Path $SymlinkPath -Target $SymlinkTarget -ErrorAction Stop | Out-Null
    Info "Symlinked: $SymlinkPath -> $SymlinkTarget"
} catch {
    Copy-Item -Path $SymlinkTarget -Destination $SymlinkPath -Force
    Info "Copied: $SymlinkPath (symlink requires Developer Mode or admin)"
}

Info "Installed: $SymlinkPath"

# --- Step 5: Ensure PATH ---
if (-not (Get-Command suvadu -ErrorAction SilentlyContinue)) {
    Warn "Adding $BinDir to PATH..."
    $env:PATH = "$BinDir;$env:PATH"

    # Persist to user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$BinDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$BinDir;$currentPath", "User")
        Info "Added $BinDir to user PATH (restart your terminal to pick it up)."
    }
}

# --- Step 6: Verify binary works ---
try {
    & $SymlinkPath --help | Out-Null
} catch {
    Error "Binary verification failed. Try downloading manually from https://github.com/$Repo/releases"
}

# --- Step 7: Auto-configure MCP clients ---
Info "Configuring MCP clients..."
& $SymlinkPath setup --auto

# --- Done ---
Write-Host ""
Info "Suvadu is ready!"
Write-Host "  Store:  " -ForegroundColor DarkGray -NoNewline; Write-Host "suvadu store `"your memory here`""
Write-Host "  Recall: " -ForegroundColor DarkGray -NoNewline; Write-Host "suvadu recall `"search query`""
Write-Host "  Help:   " -ForegroundColor DarkGray -NoNewline; Write-Host "suvadu --help"
Write-Host ""
Write-Host "Tip: Install a new AI tool later? Run 'suvadu setup --auto' to connect it." -ForegroundColor DarkGray
Write-Host ""
