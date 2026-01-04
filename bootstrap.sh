#!/bin/bash

# Bootstrap script for Terminal Setup
# This script installs Ansible and runs the setup playbook

set -e

echo "🚀 Terminal Development Environment Bootstrap"
echo "=============================================="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "📍 Detected OS: $OS"
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "📦 Ansible not found. Installing..."
    
    if [[ "$OS" == "macos" ]]; then
        # Install Homebrew if not installed
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        echo "Installing Ansible via Homebrew..."
        brew install ansible
        
    elif [[ "$OS" == "linux" ]]; then
        echo "Installing Ansible via apt..."
        sudo apt update
        sudo apt install -y ansible git
    fi
else
    echo "✅ Ansible already installed ($(ansible --version | head -n1))"
fi

echo ""
echo "🎯 Starting installation..."
echo ""

# Run the playbook (ask for sudo password on Linux)
if [[ "$OS" == "linux" ]]; then
    echo "⚠️  You will be prompted for your sudo password..."
    ansible-playbook playbook.yml --ask-become-pass "$@"
else
    ansible-playbook playbook.yml "$@"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
if [[ "$OS" == "macos" ]]; then
    echo "  1. Restart your terminal or run: source ~/.zshrc"
else
    echo "  1. Restart your terminal or run: source ~/.bashrc"
fi
if [[ "$OS" == "linux" ]]; then
    echo "  2. For Docker: log out and back in, or run: newgrp docker"
fi
echo "  3. Configure Git (if not already done):"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your@email.com\""
echo "  4. Run 'thelp' to see available commands"
echo ""
echo "🎉 Happy coding!"

