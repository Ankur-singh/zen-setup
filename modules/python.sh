#!/bin/bash
# modules/python.sh - Python tooling installation module
# Replaces roles/python/ Ansible role
# Installs UV (modern Python package manager)

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"

# Install UV (Python package manager)
install_uv() {
    if command -v uv &>/dev/null; then
        success "UV already installed"
        return 0
    fi

    info "Installing UV (Python package manager)..."

    # Set installation directory
    export UV_INSTALL_DIR="$HOME/.local/bin"

    # Install UV using official installer
    curl -LsSf https://astral.sh/uv/install.sh 2>>"$LOG_FILE" | sh >>"$LOG_FILE" 2>&1

    if command -v uv &>/dev/null; then
        success "Installed UV"
    else
        error "Failed to install UV"
        return 1
    fi
}

# Create UV directories
setup_uv_directories() {
    info "Setting up UV directories..."

    # Create config directory
    mkdir -p "$HOME/.config/uv"

    # Create cache directory
    mkdir -p "$HOME/.cache/uv"

    success "Created UV directories"
}

# Main installation function
install_python() {
    print_section "🐍 Installing Python Tools"

    # Install UV
    install_uv

    # Setup directories
    setup_uv_directories

    echo ""
    info "Python Setup Complete"
    echo ""
    echo "UV (Python package manager) has been installed!"
    echo ""
    echo "UV is a fast Python package manager from Astral (creators of Ruff)."
    echo ""
    echo "Common commands:"
    echo "  uv venv                  Create virtual environment"
    echo "  uv pip install <pkg>     Install package"
    echo "  uv pip list              List installed packages"
    echo "  uv pip freeze            Export requirements"
    echo "  uv python install 3.12   Install Python 3.12"
    echo "  uv python list           List available Python versions"
    echo ""
    echo "Documentation: https://docs.astral.sh/uv/"
    echo ""

    success "Python tools installation complete"
}

# Export the main function
export -f install_python
