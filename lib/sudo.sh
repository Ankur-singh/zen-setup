#!/bin/bash
# lib/sudo.sh - Robust sudo password handling
#
# Provides multiple fallback strategies for handling sudo authentication
# in different environments (interactive terminals, automation tools, CI/CD, etc.)

# Source utilities for pretty output
# Note: Don't redefine SCRIPT_DIR here to avoid conflicts
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_DIR/utils.sh"

# Global variables for sudo password management
SUDO_PASSWORD=""
SUDO_NEEDS_PASSWORD=false

# Check if sudo needs password
# Returns: 0 if no password needed, 1 if password required
check_sudo_needs_password() {
    if sudo -n true 2>/dev/null; then
        SUDO_NEEDS_PASSWORD=false
        return 0
    fi
    SUDO_NEEDS_PASSWORD=true
    return 1
}

# Detect if running on macOS
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Prompt for sudo password with multiple fallback strategies
# This function tries multiple approaches to get the sudo password:
# 1. Environment variable (ANSIBLE_BECOME_PASS)
# 2. /dev/tty if available (works in most interactive terminals)
# 3. stdin if terminal is attached
# 4. ssh-askpass if available (GUI fallback)
prompt_sudo_password() {
    # Skip if on macOS or password already set
    if is_macos || [[ -n "$SUDO_PASSWORD" ]]; then
        return 0
    fi

    # Check if sudo needs password
    if ! check_sudo_needs_password; then
        skip "Sudo password not required (NOPASSWD configured or valid cached credentials)"
        return 0
    fi

    echo ""
    warn "Sudo password required for system package installation"
    echo ""

    # Strategy 1: Try environment variable first
    if [[ -n "$ANSIBLE_BECOME_PASS" ]]; then
        SUDO_PASSWORD="$ANSIBLE_BECOME_PASS"
        info "Using sudo password from ANSIBLE_BECOME_PASS environment variable"
        return 0
    fi

    # Strategy 2: Try /dev/tty if available (most reliable for interactive terminals)
    if [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        echo -n "Enter sudo password: "
        if read -s SUDO_PASSWORD < /dev/tty 2>/dev/null; then
            echo ""
            info "Password read from /dev/tty"
            return 0
        fi
        echo ""
    fi

    # Strategy 3: Try stdin if terminal is attached
    if [[ -t 0 ]]; then
        echo -n "Enter sudo password: "
        if read -s SUDO_PASSWORD 2>/dev/null; then
            echo ""
            info "Password read from stdin"
            return 0
        fi
        echo ""
    fi

    # Strategy 4: Use askpass if available (GUI fallback)
    if command -v ssh-askpass &>/dev/null; then
        if SUDO_PASSWORD=$(ssh-askpass "Enter sudo password for Zen setup:" 2>/dev/null); then
            info "Password read from ssh-askpass"
            return 0
        fi
    fi

    # If all strategies fail, provide clear error with solutions
    echo ""
    error "Cannot read sudo password. Please use one of these options:"
    echo ""
    echo "  Option 1: Set environment variable before running:"
    echo "    export ANSIBLE_BECOME_PASS='your_password'"
    echo "    ./install.sh"
    echo ""
    echo "  Option 2: Configure NOPASSWD for sudo (add to /etc/sudoers.d/zen-setup):"
    echo "    $USER ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg"
    echo ""
    echo "  Option 3: Run in an interactive terminal"
    echo ""
    exit 1
}

# Run command with sudo using stored password
# Usage: run_sudo command [args...]
run_sudo() {
    if [[ -n "$SUDO_PASSWORD" ]]; then
        # Use stored password
        echo "$SUDO_PASSWORD" | sudo -S "$@" 2>&1 | grep -v "^\[sudo\] password"
    else
        # No password needed or on macOS
        sudo "$@"
    fi
}

# Validate sudo password works
# Returns: 0 if validation successful, 1 if password incorrect
validate_sudo_password() {
    # Skip validation if no password set (NOPASSWD or macOS)
    if [[ -z "$SUDO_PASSWORD" ]]; then
        return 0
    fi

    # Test the password
    if echo "$SUDO_PASSWORD" | sudo -S true 2>/dev/null; then
        success "Sudo authentication successful"
        return 0
    else
        error "Sudo password incorrect"
        return 1
    fi
}

# Keep sudo session alive
# This function can be called periodically to prevent sudo timeout
refresh_sudo() {
    if [[ -n "$SUDO_PASSWORD" ]]; then
        echo "$SUDO_PASSWORD" | sudo -S true 2>/dev/null
    else
        sudo -n true 2>/dev/null
    fi
}

# Export functions for use in other scripts
export -f check_sudo_needs_password
export -f is_macos
export -f prompt_sudo_password
export -f run_sudo
export -f validate_sudo_password
export -f refresh_sudo
