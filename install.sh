#!/bin/bash
# One-liner installer for Zen - Complete Terminal Environment
# Usage: curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash

REPO_URL="https://github.com/Ankur-singh/zen-setup.git"
INSTALL_DIR="${ZEN_SETUP_DIR:-$HOME/.local/share/zen-setup}"

echo "🧘 Zen - Terminal Environment Installer"
echo "=============================================="
echo ""
echo "📍 Installing to: $INSTALL_DIR"
echo ""

# Ensure parent directory exists
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone repository if not exists
if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Directory $INSTALL_DIR already exists"
    read -p "Update existing installation? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$INSTALL_DIR"
        echo "📥 Pulling latest changes..."
        if ! git pull; then
            echo ""
            echo "❌ Git pull failed!"
            echo "💡 You can retry by running: bash $INSTALL_DIR/bootstrap.sh"
            exit 1
        fi
    else
        echo "❌ Installation cancelled"
        exit 1
    fi
else
    echo "📥 Cloning repository..."
    if ! git clone "$REPO_URL" "$INSTALL_DIR"; then
        echo ""
        echo "❌ Git clone failed!"
        echo "💡 Please check your internet connection and try again."
        exit 1
    fi
    cd "$INSTALL_DIR"
fi

echo ""
echo "🎯 Running bootstrap script..."
echo ""

# Run bootstrap with error handling
if ! bash "$INSTALL_DIR/bootstrap.sh" "$@"; then
    echo ""
    echo "❌ Installation failed!"
    echo "💡 You can retry by running: bash $INSTALL_DIR/bootstrap.sh"
    exit 1
fi

echo ""
echo "💡 Tip: Run 'zupdate' in the future to update your setup!"

