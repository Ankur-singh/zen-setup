#!/bin/bash
# modules/git.sh - Git configuration module
# Installs git tools and configures aliases (NO user.name/user.email setup)

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"

# Configure git settings
configure_git() {
    info "Configuring git settings..."

    # Default branch name
    git config --global init.defaultBranch main

    # Pull strategy
    git config --global pull.rebase false

    # Credential helper (platform-specific)
    if is_macos; then
        git config --global credential.helper osxkeychain
    else
        git config --global credential.helper "cache --timeout=3600"
    fi

    # Enable colors
    git config --global color.ui auto
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.status auto

    success "Configured git settings"
}

# Configure git aliases
configure_git_aliases() {
    info "Configuring git aliases..."

    # Useful shortcuts
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.amend "commit --amend --no-edit"
    git config --global alias.undo "reset --soft HEAD~1"

    success "Configured git aliases"
}

# Configure git-delta (if installed)
configure_delta() {
    if ! command -v delta &>/dev/null; then
        skip "git-delta not installed, skipping delta configuration"
        return 0
    fi

    info "Configuring git-delta for beautiful diffs..."

    # Configure delta as pager
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate "true"
    git config --global delta.side-by-side "true"
    git config --global delta.line-numbers "true"
    git config --global merge.conflictStyle "zdiff3"

    success "Configured git-delta"
}

# Print post-installation message
print_git_message() {
    echo ""
    info "Git Configuration Complete"
    echo ""
    echo "Next steps:"
    echo "  1. Set your Git identity (if not already set):"
    echo "       git config --global user.name \"Your Name\""
    echo "       git config --global user.email \"your@email.com\""
    echo ""
    echo "  2. Authenticate with GitHub CLI:"
    echo "       gh auth login"
    echo ""

    if command -v delta &>/dev/null; then
        echo "  ✨ git-delta is configured for beautiful diffs!"
        echo ""
    fi
}

# Main installation function
install_git() {
    local profile="${PROFILE:-enhanced}"

    print_section "🔧 Installing Git"

    # Install git and gh packages
    if is_macos; then
        if ! brew list git &>/dev/null; then
            brew install git >>"$LOG_FILE" 2>&1 && \
                success "Installed git" || \
                error "Failed to install git"
        else
            success "git already installed"
        fi

        if ! brew list gh &>/dev/null; then
            brew install gh >>"$LOG_FILE" 2>&1 && \
                success "Installed GitHub CLI (gh)" || \
                error "Failed to install gh"
        else
            success "GitHub CLI already installed"
        fi
    elif is_linux; then
        if ! command -v git &>/dev/null || ! command -v gh &>/dev/null; then
            pkg_install git gh >>"$LOG_FILE" 2>&1 && \
                success "Installed git and gh" || \
                error "Failed to install git/gh"
        else
            success "git and gh already installed"
        fi
    fi

    # Skip configuration in core profile
    if [[ "$profile" == "core" ]]; then
        info "Skipping git configuration (core profile - no customizations)"
        return 0
    fi

    # Enhanced profile - apply full configuration
    print_section "🔧 Configuring Git"
    info "Applying git configuration..."

    # Configure git
    configure_git
    configure_git_aliases
    configure_delta

    # Print message
    print_git_message

    success "Git configuration complete"
}

# Export the main function
export -f install_git
