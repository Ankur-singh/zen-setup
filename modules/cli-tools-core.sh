#!/bin/bash
# modules/cli-tools-core.sh - Core CLI tools (essential, non-replacement tools)
# Installs tools that provide NEW functionality without replacing built-ins

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"
source "$_MODULE_DIR/../lib/sudo.sh"

# Fallback versions (used when GitHub API is rate-limited)
LAZYGIT_VERSION="0.58.0"
LAZYDOCKER_VERSION="0.23.3"
GUM_VERSION="0.14.5"

# Get latest version from GitHub or use fallback
get_latest_version() {
    local repo="$1"
    local fallback="$2"

    local version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | \
                    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [[ -n "$version" ]]; then
        # Remove 'v' prefix if present
        echo "${version#v}"
    else
        echo "$fallback"
    fi
}

# Install core CLI tools on macOS via Homebrew
install_cli_tools_core_macos() {
    info "Installing core CLI tools via Homebrew"

    # Core packages - essential tools only
    local packages=(
        "jq"            # JSON processor
        "htop"          # Process viewer
        "curl"
        "wget"
        "git"
        "gh"            # GitHub CLI
        "tmux"
        "lazygit"       # Git TUI
        "lazydocker"    # Docker TUI
        "tree"          # Directory tree
        "gum"           # TUI for interactive mode
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            skip "$package already installed"
        else
            info "Installing $package..."
            brew install "$package" >>"$LOG_FILE" 2>&1 && \
                success "Installed $package" || \
                error "Failed to install $package"
        fi
    done
}

# Install core CLI tools on Linux
install_cli_tools_core_linux() {
    info "Installing core CLI tools on Linux"

    # Update package cache first
    pkg_update >>"$LOG_FILE" 2>&1

    # APT packages
    info "Installing base packages from APT..."
    local apt_packages=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "software-properties-common"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "unzip"
        "tar"
        "gzip"
        "jq"
        "htop"
        "tree"
        "tmux"
        "xclip"
        "bash-completion"
    )

    pkg_install "${apt_packages[@]}" >>"$LOG_FILE" 2>&1 && \
        success "Installed APT packages" || \
        error "Failed to install APT packages"

    # Install lazygit
    install_lazygit_linux

    # Install lazydocker
    install_lazydocker_linux

    # Install gum (TUI for interactive mode)
    install_gum_linux
}

# Install lazygit on Linux (GitHub release)
install_lazygit_linux() {
    if command -v lazygit &>/dev/null; then
        skip "lazygit already installed"
        return 0
    fi

    info "Installing lazygit..."
    local version=$(get_latest_version "jesseduffield/lazygit" "$LAZYGIT_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    curl -fsSLo lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz" 2>>"$LOG_FILE"

    tar xzf lazygit.tar.gz
    install -m 755 lazygit "$HOME/.local/bin/lazygit"
    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed lazygit v${version}"
}

# Install lazydocker on Linux (GitHub release)
install_lazydocker_linux() {
    if command -v lazydocker &>/dev/null; then
        skip "lazydocker already installed"
        return 0
    fi

    info "Installing lazydocker..."
    local version=$(get_latest_version "jesseduffield/lazydocker" "$LAZYDOCKER_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    curl -fsSLo lazydocker.tar.gz \
        "https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_Linux_x86_64.tar.gz" 2>>"$LOG_FILE"

    tar xzf lazydocker.tar.gz
    install -m 755 lazydocker "$HOME/.local/bin/lazydocker"
    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed lazydocker v${version}"
}

# Install gum on Linux (GitHub release .deb)
install_gum_linux() {
    if command -v gum &>/dev/null; then
        skip "gum already installed"
        return 0
    fi

    info "Installing gum..."
    local version=$(get_latest_version "charmbracelet/gum" "$GUM_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    wget -q "https://github.com/charmbracelet/gum/releases/download/v${version}/gum_${version}_amd64.deb" \
        -O gum.deb 2>>"$LOG_FILE"

    run_sudo dpkg -i gum.deb >>"$LOG_FILE" 2>&1 || \
        run_sudo apt-get install -f -y >>"$LOG_FILE" 2>&1

    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed gum v${version}"
}

# Configure tool configs (lazygit)
configure_tools() {
    local config_dir="$HOME/.config"
    local config_source="$_MODULE_DIR/../config"

    # Configure lazygit
    if command -v lazygit &>/dev/null; then
        info "Configuring lazygit..."

        if is_macos; then
            local lazygit_dir="$HOME/Library/Application Support/lazygit"
        else
            local lazygit_dir="$config_dir/lazygit"
        fi

        mkdir -p "$lazygit_dir"

        if [[ -f "$config_source/lazygit/config.yml" ]]; then
            cp "$config_source/lazygit/config.yml" "$lazygit_dir/config.yml"
            success "Configured lazygit"
        else
            warn "lazygit config not found in $config_source/lazygit/"
        fi
    fi
}

# Main installation function
install_cli_tools_core() {
    print_section "⚡ Installing Core CLI Tools"

    # Install platform-specific CLI tools
    if is_macos; then
        install_cli_tools_core_macos
    elif is_linux; then
        install_cli_tools_core_linux
    else
        error "Unsupported platform"
        return 1
    fi

    # Configure tools
    configure_tools

    success "Core CLI tools installation complete"
}

# Export the main function
export -f install_cli_tools_core
