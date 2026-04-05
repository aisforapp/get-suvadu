#!/bin/bash
# Suvadu installer — download, extract, and configure for all detected MCP clients.
# Usage: curl -fsSL https://suvadu.aisforapp.com/install.sh | bash
set -euo pipefail

REPO="aisforapp/get-suvadu"
INSTALL_DIR="$HOME/.local/lib/suvadu"
BIN_DIR="$HOME/.local/bin"
BINARY_NAME="suvadu"
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info()  { echo -e "${GREEN}==>${RESET} ${BOLD}$1${RESET}"; }
warn()  { echo -e "${YELLOW}==>${RESET} ${BOLD}$1${RESET}"; }
error() { echo -e "${RED}==>${RESET} ${BOLD}$1${RESET}"; exit 1; }

# --- Step 1: Detect platform ---
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin) PLATFORM="darwin" ;;
    Linux)  PLATFORM="linux" ;;
    *)      error "Unsupported OS: $OS" ;;
esac

case "$ARCH" in
    x86_64)  ARCH="x86_64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)       error "Unsupported architecture: $ARCH" ;;
esac

ASSET_NAME="suvadu-${PLATFORM}-${ARCH}.tar.gz"
info "Detected platform: ${PLATFORM}-${ARCH}"

# --- Step 2: Download latest tarball from GitHub Releases ---
info "Downloading suvadu..."
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ASSET_NAME}"
TMP_DIR="$(mktemp -d)"

if command -v curl &> /dev/null; then
    curl -fsSL -o "$TMP_DIR/$ASSET_NAME" "$DOWNLOAD_URL" || error "Download failed. Check https://github.com/${REPO}/releases"
elif command -v wget &> /dev/null; then
    wget -q -O "$TMP_DIR/$ASSET_NAME" "$DOWNLOAD_URL" || error "Download failed. Check https://github.com/${REPO}/releases"
else
    error "Neither curl nor wget found. Install one and retry."
fi

# --- Step 3: Extract and install ---
info "Installing..."
rm -rf "$INSTALL_DIR"
mkdir -p "$(dirname "$INSTALL_DIR")"
tar -xzf "$TMP_DIR/$ASSET_NAME" -C "$(dirname "$INSTALL_DIR")"
chmod +x "$INSTALL_DIR/$BINARY_NAME"
rm -rf "$TMP_DIR"

# Symlink binary to bin dir
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/$BINARY_NAME" "$BIN_DIR/$BINARY_NAME"
info "Installed: $BIN_DIR/$BINARY_NAME"

# --- Step 4: Ensure PATH ---
if ! command -v suvadu &> /dev/null; then
    warn "Adding $BIN_DIR to PATH..."
    export PATH="$BIN_DIR:$PATH"

    SHELL_NAME="$(basename "$SHELL")"
    case "$SHELL_NAME" in
        zsh)  PROFILE="$HOME/.zshrc" ;;
        bash) PROFILE="$HOME/.bashrc" ;;
        *)    PROFILE="" ;;
    esac
    if [ -n "$PROFILE" ] && ! grep -q "$BIN_DIR" "$PROFILE" 2>/dev/null; then
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$PROFILE"
        info "Added to $PROFILE (restart shell or run: source $PROFILE)"
    fi
fi

# --- Step 5: Verify binary works ---
if ! "$BIN_DIR/$BINARY_NAME" --help &> /dev/null; then
    error "Binary verification failed. Try downloading manually from https://github.com/${REPO}/releases"
fi

# --- Step 6: Auto-configure MCP clients ---
info "Configuring MCP clients..."
"$BIN_DIR/$BINARY_NAME" setup --auto

# --- Done ---
echo ""
info "Suvadu is ready!"
echo -e "  ${DIM}Store:${RESET}  suvadu store \"your memory here\""
echo -e "  ${DIM}Recall:${RESET} suvadu recall \"search query\""
echo -e "  ${DIM}Help:${RESET}   suvadu --help"
echo ""
echo -e "${DIM}Tip: Install a new AI tool later? Run 'suvadu setup --auto' to connect it.${RESET}"
echo ""
