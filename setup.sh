#!/bin/bash
# setup.sh - Main orchestrator for Zen setup

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/platform.sh"
source "$SCRIPT_DIR/lib/sudo.sh"
source "$SCRIPT_DIR/lib/backup.sh"

# Default values
PROFILE="enhanced"
COMPONENTS=()
VERBOSE=false
SKIP_BACKUP=false

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --core)
                PROFILE="core"
                shift
                ;;
            --enhanced)
                PROFILE="enhanced"
                shift
                ;;
            --components)
                IFS=',' read -ra COMPONENTS <<< "$2"
                shift 2
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    cat << 'EOF'
Zen Setup - Complete Terminal Environment

Usage: ./setup.sh [OPTIONS]

Options:
  --enhanced          Install enhanced profile with shell customizations (default)
  --core              Install core dev tools with default configs (cli-tools, docker, python, nvidia)
  --components LIST   Install specific components (comma-separated)
                      Available: shell,cli-tools,git,tmux,docker,python,nvidia
  --verbose, -v       Enable verbose output
  --skip-backup       Skip backing up existing dotfiles
  --help, -h          Show this help message

Profiles:
  enhanced (default)  Complete experience: shell + cli-tools + custom git/tmux configs
  core                Tools only: cli-tools (git, tmux, etc.) with system defaults

Examples:
  ./setup.sh                               # Install enhanced profile (default)
  ./setup.sh --core                        # Install core profile (tools only, no custom configs)
  ./setup.sh --components shell,cli-tools  # Install specific components

EOF
}

# Get components for profile
get_profile_components() {
    local profile=$1

    case "$profile" in
        core)
            # Core: Essential dev tools with default configurations only
            # cli-tools installs git, gh, tmux, etc. but no custom configs
            echo "cli-tools docker python nvidia"
            ;;
        enhanced)
            # Enhanced: Complete Zen experience with shell customizations
            # Adds shell config + git/tmux custom configurations
            echo "shell cli-tools git tmux docker python nvidia"
            ;;
        *)
            error "Unknown profile: $profile (use --core or --enhanced)"
            exit 1
            ;;
    esac
}

# Install prerequisites
install_prerequisites() {
    print_section "Prerequisites"

    if is_macos; then
        # macOS: Install Homebrew if needed
        if ! command -v brew &>/dev/null; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"$LOG_FILE" 2>&1 && \
                success "Installed Homebrew" || \
                { error "Failed to install Homebrew"; exit 1; }

            # Add brew to path for this session
            if [[ -x "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -x "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        else
            success "Homebrew already installed"
        fi
    elif is_linux; then
        # Linux: Ensure git is installed
        if ! command -v git &>/dev/null; then
            info "Installing git..."
            pkg_install git >>"$LOG_FILE" 2>&1 && \
                success "Installed git" || \
                { error "Failed to install git"; exit 1; }
        else
            success "git already installed"
        fi
    fi
}

# Install a single component
install_component() {
    local component=$1
    local module_file="$SCRIPT_DIR/modules/${component}.sh"

    if [[ ! -f "$module_file" ]]; then
        error "Module not found: $component"
        return 1
    fi

    # Source the module
    source "$module_file"

    # Call the install function
    local install_func="install_${component//-/_}"  # Convert hyphens to underscores

    if declare -f "$install_func" &>/dev/null; then
        $install_func
    else
        error "Install function not found: $install_func"
        return 1
    fi
}

# Print banner
print_banner() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                                           ║${NC}"
    echo -e "${BOLD}║     ${CYAN}禅${NC}  ${BOLD}Zen Setup${NC}  ${CYAN}全${NC}                     ${BOLD}║${NC}"
    echo -e "${BOLD}║     ${DIM}Complete Terminal Environment${NC}        ${BOLD}║${NC}"
    echo -e "${BOLD}║                                           ║${NC}"
    echo -e "${BOLD}╚═══════════════════════════════════════════╝${NC}"
    echo ""
}

# Print summary
print_summary() {
    local components=("$@")
    local shell=$(detect_shell)

    echo ""
    print_completion
    echo ""
    info "Installation Summary:"
    echo "  Components: ${components[*]}"
    echo "  Shell:      $shell"
    echo ""

    if is_linux; then
        warn "IMPORTANT: Reload your shell to apply changes"
        echo "  exec $shell"
        echo ""
        if echo "${components[@]}" | grep -q "docker"; then
            warn "For Docker: Log out and log back in (or run: newgrp docker)"
            echo ""
        fi
        if echo "${components[@]}" | grep -q "nvidia"; then
            if [[ ! -f /var/run/reboot-required ]] && ! nvidia-smi &>/dev/null; then
                warn "For NVIDIA: Reboot required to activate drivers"
                echo "  sudo reboot"
                echo ""
            fi
        fi
    elif is_macos; then
        warn "Reload your shell to apply changes:"
        echo "  exec $shell"
        echo ""
    fi

    info "Quick commands:"
    echo "  zhelp     Show command reference"
    echo "  zdoctor   Health check installation"
    echo "  zupdate   Update Zen setup"
    echo ""
}

# Main function
main() {
    # Parse arguments
    parse_args "$@"

    # Initialize logging
    local log_dir="$HOME/.local/share/zen-setup/logs"
    init_logging "$log_dir"

    # Print banner
    print_banner

    # Show platform info
    print_platform_info

    # Determine components to install
    if [[ ${#COMPONENTS[@]} -eq 0 ]]; then
        COMPONENTS=($(get_profile_components "$PROFILE"))
    fi

    echo ""
    info "Profile:    $PROFILE"
    info "Components: ${COMPONENTS[*]}"
    echo ""

    # Backup dotfiles (only for components that modify configs)
    if [[ "$SKIP_BACKUP" == false ]]; then
        backup_dotfiles_for_components "${COMPONENTS[@]}"
    fi

    # Install prerequisites
    install_prerequisites

    # Prompt for sudo password (Linux only)
    if is_linux; then
        prompt_sudo_password
        validate_sudo_password || exit 1
    fi

    # Install each component
    local failed_components=()
    for component in "${COMPONENTS[@]}"; do
        # Skip nvidia on macOS
        if [[ "$component" == "nvidia" ]] && is_macos; then
            skip "nvidia (macOS - not applicable)"
            continue
        fi

        if ! install_component "$component"; then
            failed_components+=("$component")
        fi
    done

    # Print summary
    if [[ ${#failed_components[@]} -gt 0 ]]; then
        echo ""
        error "Some components failed to install: ${failed_components[*]}"
        echo "Check logs at: $LOG_FILE"
        exit 1
    fi

    print_summary "${COMPONENTS[@]}"

    # Export Zen setup directory for future use
    echo "export ZEN_SETUP_DIR=\"$SCRIPT_DIR\"" >> "$(get_shell_rc)"

    success "Setup complete! 🎉"
}

# Run main function
main "$@"
