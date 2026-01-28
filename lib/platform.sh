#!/bin/bash
# lib/platform.sh - Centralized platform detection and abstraction
#
# Single source of truth for platform detection, package management,
# and platform-specific behavior

# Source utilities for pretty output
# Note: Don't redefine SCRIPT_DIR here to avoid conflicts
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_DIR/utils.sh"

# Detect operating system
# Returns: macos, debian, rhel, or unknown
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# Boolean helper: Check if running on macOS
is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

# Boolean helper: Check if running on Linux
is_linux() {
    local os=$(detect_os)
    [[ "$os" == "debian" ]] || [[ "$os" == "rhel" ]]
}

# Boolean helper: Check if running on Debian/Ubuntu
is_debian() {
    [[ "$(detect_os)" == "debian" ]]
}

# Boolean helper: Check if running on RHEL/CentOS/Fedora
is_rhel() {
    [[ "$(detect_os)" == "rhel" ]]
}

# Detect shell (zsh on macOS, bash on Linux by default)
# Returns: zsh or bash
detect_shell() {
    if is_macos; then
        echo "zsh"
    else
        echo "bash"
    fi
}

# Get shell RC file path
# Returns: Full path to ~/.zshrc or ~/.bashrc
get_shell_rc() {
    local shell=$(detect_shell)
    if [[ "$shell" == "zsh" ]]; then
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    fi
}

# Get shell profile file path (for PATH modifications)
# Returns: Full path to shell profile
get_shell_profile() {
    if is_macos; then
        echo "$HOME/.zprofile"
    else
        echo "$HOME/.bash_profile"
    fi
}

# Detect package manager
# Returns: brew, apt, dnf, or unknown
detect_package_manager() {
    if command -v brew &>/dev/null; then
        echo "brew"
    elif command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# Install package using platform-specific package manager
# Usage: pkg_install package1 [package2 ...]
pkg_install() {
    local packages=("$@")
    local pkg_mgr=$(detect_package_manager)

    case "$pkg_mgr" in
        brew)
            brew install "${packages[@]}"
            ;;
        apt)
            # Source sudo.sh for run_sudo function if not already sourced
            if ! type run_sudo &>/dev/null; then
                source "$_LIB_DIR/sudo.sh"
            fi
            run_sudo apt install -y "${packages[@]}"
            ;;
        dnf)
            if ! type run_sudo &>/dev/null; then
                source "$_LIB_DIR/sudo.sh"
            fi
            run_sudo dnf install -y "${packages[@]}"
            ;;
        *)
            error "Unknown package manager"
            return 1
            ;;
    esac
}

# Update package manager cache
# Usage: pkg_update
pkg_update() {
    local pkg_mgr=$(detect_package_manager)

    case "$pkg_mgr" in
        brew)
            brew update
            ;;
        apt)
            if ! type run_sudo &>/dev/null; then
                source "$_LIB_DIR/sudo.sh"
            fi
            run_sudo apt update
            ;;
        dnf)
            if ! type run_sudo &>/dev/null; then
                source "$_LIB_DIR/sudo.sh"
            fi
            run_sudo dnf check-update || true
            ;;
        *)
            error "Unknown package manager"
            return 1
            ;;
    esac
}

# Check if running on ARM64 architecture
is_arm64() {
    [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]
}

# Check if running on x86_64 architecture
is_x86_64() {
    [[ "$(uname -m)" == "x86_64" ]]
}

# Get architecture string
get_arch() {
    uname -m
}

# Detect if NVIDIA GPU is present (Linux only)
# Returns: 0 if NVIDIA GPU found, 1 otherwise
has_nvidia_gpu() {
    if ! is_linux; then
        return 1
    fi

    if command -v lspci &>/dev/null; then
        lspci | grep -i nvidia &>/dev/null
        return $?
    fi

    return 1
}

# Get Ubuntu/Debian version
get_ubuntu_version() {
    if is_debian; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "$VERSION_ID"
        fi
    fi
}

# Get Ubuntu/Debian codename
get_ubuntu_codename() {
    if is_debian; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "$VERSION_CODENAME"
        fi
    fi
}

# Get macOS version
get_macos_version() {
    if is_macos; then
        sw_vers -productVersion
    fi
}

# Print platform information
print_platform_info() {
    local os=$(detect_os)
    local shell=$(detect_shell)
    local arch=$(get_arch)
    local pkg_mgr=$(detect_package_manager)

    echo ""
    info "Platform Information:"
    echo "  OS:              $os"
    echo "  Architecture:    $arch"
    echo "  Shell:           $shell"
    echo "  Package Manager: $pkg_mgr"

    if is_debian; then
        local version=$(get_ubuntu_version)
        local codename=$(get_ubuntu_codename)
        echo "  Version:         $version ($codename)"
    elif is_macos; then
        local version=$(get_macos_version)
        echo "  Version:         $version"
    fi

    if has_nvidia_gpu; then
        echo "  NVIDIA GPU:      detected"
    fi
    echo ""
}

# Export functions for use in other scripts
export -f detect_os
export -f is_macos
export -f is_linux
export -f is_debian
export -f is_rhel
export -f detect_shell
export -f get_shell_rc
export -f get_shell_profile
export -f detect_package_manager
export -f pkg_install
export -f pkg_update
export -f is_arm64
export -f is_x86_64
export -f get_arch
export -f has_nvidia_gpu
export -f get_ubuntu_version
export -f get_ubuntu_codename
export -f get_macos_version
export -f print_platform_info
