#!/bin/bash
# modules/cli-tools-enhanced.sh - Enhanced CLI tools (all tools including replacements)
# Installs all core tools PLUS modern replacements for built-ins and nice-to-haves

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"
source "$_MODULE_DIR/../lib/sudo.sh"

# Fallback versions (used when GitHub API is rate-limited)
LAZYGIT_VERSION="0.58.0"
LAZYDOCKER_VERSION="0.23.3"
BTOP_VERSION="1.4.6"
FASTFETCH_VERSION="2.56.1"
DELTA_VERSION="0.18.2"
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

# Install enhanced CLI tools on macOS via Homebrew
install_cli_tools_enhanced_macos() {
    info "Installing enhanced CLI tools via Homebrew"

    # All packages - core + replacements + enhancements
    local packages=(
        # Core tools
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
        # Built-in replacements
        "eza"           # Modern ls
        "bat"           # Better cat
        "fzf"           # Fuzzy finder
        "zoxide"        # Smart cd
        "ripgrep"       # Fast grep
        "fd"            # Fast find
        # Enhancements
        "btop"          # System monitor
        "fastfetch"     # System info
        "git-delta"     # Beautiful git diffs
        "tldr"          # Simplified man pages
        "mosh"          # Mobile shell
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

    # Install Nerd Fonts (optional, may take time)
    info "Installing Nerd Fonts..."
    brew install --cask font-meslo-lg-nerd-font >>"$LOG_FILE" 2>&1 && \
        success "Installed Meslo Nerd Font" || \
        skip "Could not install Meslo Nerd Font"

    brew install --cask font-fira-code-nerd-font >>"$LOG_FILE" 2>&1 && \
        success "Installed Fira Code Nerd Font" || \
        skip "Could not install Fira Code Nerd Font"

    # Initialize fzf key bindings
    info "Initializing fzf key bindings..."
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash >>"$LOG_FILE" 2>&1 && \
        success "Initialized fzf" || \
        error "Failed to initialize fzf"
}

# Install enhanced CLI tools on Linux
install_cli_tools_enhanced_linux() {
    info "Installing enhanced CLI tools on Linux"

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
        "ripgrep"
        "fd-find"
        "tmux"
        "xclip"
        "bash-completion"
        "mosh"          # Mobile shell
    )

    pkg_install "${apt_packages[@]}" >>"$LOG_FILE" 2>&1 && \
        success "Installed APT packages" || \
        error "Failed to install APT packages"

    # Install eza (modern ls replacement)
    install_eza_linux

    # Install bat (better cat)
    install_bat_linux

    # Install fzf (fuzzy finder)
    install_fzf_linux

    # Install zoxide (smart cd)
    install_zoxide_linux

    # Install lazygit
    install_lazygit_linux

    # Install lazydocker
    install_lazydocker_linux

    # Install btop (system monitor)
    install_btop_linux

    # Install fastfetch (system info)
    install_fastfetch_linux

    # Install git-delta (beautiful diffs)
    install_delta_linux

    # Install gum (TUI for interactive mode)
    install_gum_linux

    # Install tldr (simplified man pages)
    install_tldr_linux
}

# Install eza on Linux (custom repository)
install_eza_linux() {
    if command -v eza &>/dev/null; then
        skip "eza already installed"
        return 0
    fi

    info "Installing eza from custom repository..."

    # Create apt keyrings directory
    run_sudo mkdir -p /etc/apt/keyrings

    # Add eza GPG key
    if [[ ! -f /etc/apt/keyrings/gierens.gpg ]]; then
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc 2>>"$LOG_FILE" | \
            run_sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        run_sudo chmod 644 /etc/apt/keyrings/gierens.gpg
    fi

    # Add eza repository
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        run_sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null

    # Install eza
    run_sudo apt update >>"$LOG_FILE" 2>&1
    pkg_install eza >>"$LOG_FILE" 2>&1 && \
        success "Installed eza" || \
        error "Failed to install eza"
}

# Install bat on Linux
install_bat_linux() {
    if command -v bat &>/dev/null; then
        skip "bat already installed"
        return 0
    fi

    info "Installing bat..."
    pkg_install bat >>"$LOG_FILE" 2>&1 && \
        success "Installed bat" || \
        error "Failed to install bat"

    # Create symlink batcat -> bat (Ubuntu/Debian naming)
    if [[ -f /usr/bin/batcat ]] && [[ ! -f "$HOME/.local/bin/bat" ]]; then
        ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
        success "Created bat symlink"
    fi
}

# Install fzf on Linux (git clone method)
install_fzf_linux() {
    if [[ -f "$HOME/.fzf/bin/fzf" ]]; then
        skip "fzf already installed"
        return 0
    fi

    info "Installing fzf from source..."

    # Clone fzf repository
    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >>"$LOG_FILE" 2>&1
    fi

    # Install fzf
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --bin >>"$LOG_FILE" 2>&1 && \
        success "Installed fzf" || \
        error "Failed to install fzf"
}

# Install zoxide on Linux (shell installer)
install_zoxide_linux() {
    if command -v zoxide &>/dev/null; then
        skip "zoxide already installed"
        return 0
    fi

    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >>"$LOG_FILE" 2>&1 && \
        success "Installed zoxide" || \
        error "Failed to install zoxide"
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

# Install btop on Linux (GitHub release)
install_btop_linux() {
    if command -v btop &>/dev/null; then
        skip "btop already installed"
        return 0
    fi

    info "Installing btop..."
    local version=$(get_latest_version "aristocratos/btop" "$BTOP_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    curl -fsSLo btop.tbz \
        "https://github.com/aristocratos/btop/releases/download/v${version}/btop-x86_64-linux-musl.tbz" 2>>"$LOG_FILE"

    tar xjf btop.tbz
    cd btop && make install PREFIX="$HOME/.local" >>"$LOG_FILE" 2>&1
    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed btop v${version}"
}

# Install fastfetch on Linux (GitHub release .deb)
install_fastfetch_linux() {
    if command -v fastfetch &>/dev/null; then
        skip "fastfetch already installed"
        return 0
    fi

    info "Installing fastfetch..."
    local version=$(get_latest_version "fastfetch-cli/fastfetch" "$FASTFETCH_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    wget -q "https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/fastfetch-linux-amd64.deb" \
        -O fastfetch.deb 2>>"$LOG_FILE"

    run_sudo dpkg -i fastfetch.deb >>"$LOG_FILE" 2>&1 || \
        run_sudo apt-get install -f -y >>"$LOG_FILE" 2>&1

    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed fastfetch ${version}"
}

# Install git-delta on Linux (GitHub release .deb)
install_delta_linux() {
    if command -v delta &>/dev/null; then
        skip "git-delta already installed"
        return 0
    fi

    info "Installing git-delta..."
    local version=$(get_latest_version "dandavison/delta" "$DELTA_VERSION")

    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    wget -q "https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_amd64.deb" \
        -O delta.deb 2>>"$LOG_FILE"

    run_sudo dpkg -i delta.deb >>"$LOG_FILE" 2>&1 || \
        run_sudo apt-get install -f -y >>"$LOG_FILE" 2>&1

    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed git-delta ${version}"
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

# Install tldr on Linux (via npm if available, otherwise via curl)
install_tldr_linux() {
    if command -v tldr &>/dev/null; then
        skip "tldr already installed"
        return 0
    fi

    info "Installing tldr..."

    # Try npm first if available
    if command -v npm &>/dev/null; then
        npm install -g tldr >>"$LOG_FILE" 2>&1 && \
            success "Installed tldr via npm" && \
            return 0
    fi

    # Fallback to tealdeer (Rust implementation)
    local tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    curl -fsSLo tldr.tar.gz \
        "https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl.tar.gz" 2>>"$LOG_FILE"

    tar xzf tldr.tar.gz
    install -m 755 tealdeer "$HOME/.local/bin/tldr"
    cd - >/dev/null
    rm -rf "$tmpdir"

    success "Installed tldr (tealdeer)"
}

# Configure tool configs (lazygit, fastfetch, btop)
configure_tools() {
    local config_dir="$HOME/.config"
    local config_source="$_MODULE_DIR/../config"

    # Configure lazygit
    if command -v lazygit &>/dev/null && command -v delta &>/dev/null; then
        info "Configuring lazygit with delta integration..."

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

    # Configure fastfetch
    if command -v fastfetch &>/dev/null; then
        info "Configuring fastfetch..."
        mkdir -p "$config_dir/fastfetch"

        if [[ -f "$config_source/fastfetch/config.jsonc" ]]; then
            cp "$config_source/fastfetch/config.jsonc" "$config_dir/fastfetch/config.jsonc"
            success "Configured fastfetch"
        else
            warn "fastfetch config not found in $config_source/fastfetch/"
        fi
    fi

    # Configure btop (create directory for user configs)
    if command -v btop &>/dev/null; then
        mkdir -p "$config_dir/btop"
        success "Created btop config directory"
    fi
}

# Main installation function
install_cli_tools_enhanced() {
    print_section "⚡ Installing Enhanced CLI Tools"

    # Install platform-specific CLI tools
    if is_macos; then
        install_cli_tools_enhanced_macos
    elif is_linux; then
        install_cli_tools_enhanced_linux
    else
        error "Unsupported platform"
        return 1
    fi

    # Configure tools
    configure_tools

    success "Enhanced CLI tools installation complete"
}

# Export the main function
export -f install_cli_tools_enhanced
