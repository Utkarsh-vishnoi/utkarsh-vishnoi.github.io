#!/bin/bash

# Script version and binary version to download
VERSION="1.0.0"
GITHUB_USER="utkarsh-vishnoi"  # TODO: Replace with actual GitHub username
REPO_NAME="utkarsh-vishnoi.github.io"           # TODO: Replace with actual repository name

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to output error message and exit
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to output success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to output info message
info() {
    echo -e "${YELLOW}$1${NC}"
}

# Detect operating system
detect_os() {
    local os
    case "$(uname -s)" in
        Darwin*)
            os="darwin"
            ;;
        Linux*)
            os="linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            os="windows"
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac
    echo "$os"
}

# Detect architecture
detect_arch() {
    local arch
    case "$(uname -m)" in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            ;;
    esac
    echo "$arch"
}

# Check if curl or wget is available
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -L -o"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -O"
else
    error "Neither curl nor wget found. Please install one of them."
fi

# Detect OS and architecture
OS=$(detect_os)
ARCH=$(detect_arch)

# Construct binary name
if [ "$OS" = "windows" ]; then
    BINARY_NAME="secure-${VERSION}-${OS}-${ARCH}.exe"
else
    BINARY_NAME="secure-${VERSION}-${OS}-${ARCH}"
fi

# Construct download URL
DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/raw/refs/heads/master/downloads/${BINARY_NAME}"

# Create temporary directory
TMP_DIR=$(mktemp -d)
if [ $? -ne 0 ]; then
    error "Failed to create temporary directory"
fi

info "🔍 Detected system: $OS ($ARCH)"
info "📥 Downloading secure upload binary..."

# Download the binary
$DOWNLOAD_CMD "$TMP_DIR/$BINARY_NAME" "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
    rm -rf "$TMP_DIR"
    error "Failed to download binary"
fi

# Make binary executable (except on Windows)
if [ "$OS" != "windows" ]; then
    chmod +x "$TMP_DIR/$BINARY_NAME"
    if [ $? -ne 0 ]; then
        rm -rf "$TMP_DIR"
        error "Failed to make binary executable"
    fi
fi

# Move binary to current directory
INSTALL_DIR=$(pwd)
mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/secure"
if [ $? -ne 0 ]; then
    rm -rf "$TMP_DIR"
    error "Failed to install binary. Try running with sudo?"
fi

# Clean up
rm -rf "$TMP_DIR"

success "✅ Installation complete!"
success "Binary downloaded to: $INSTALL_DIR/secure"

if [ "$OS" = "windows" ]; then
    info "📝 Note: On Windows, you may need to add $INSTALL_DIR to your PATH"
fi

echo ""
info "To start the secure upload server, run:"
echo "secure"
