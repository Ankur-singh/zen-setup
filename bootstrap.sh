#!/bin/bash
# Zen - Complete Terminal Environment
# Bootstrap script with pretty output

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/profiles.sh"

# Default configuration
PROFILE="standard"
VERBOSE=false
INTERACTIVE=false
DRY_RUN=false
SKIP_PREREQS=false
TAGS=""

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -i|--interactive)
        INTERACTIVE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --minimal)
        PROFILE="minimal"
        shift
        ;;
      --tags)
        TAGS="$2"
        shift 2
        ;;
      --skip-prereqs)
        SKIP_PREREQS=true
        shift
        ;;
      *)
        # Pass unknown args to ansible-playbook
        EXTRA_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

show_help() {
  echo "Zen - Complete Terminal Environment"
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Profiles:"
  echo "  (default)       Full setup: shell, cli-tools, tmux, neovim, git, docker, python"
  echo "  --minimal       Lightweight: shell, cli-tools, tmux, git, python (no neovim, docker)"
  echo ""
  echo "Options:"
  echo "  -i, --interactive   Choose components interactively"
  echo "  -v, --verbose       Show detailed output"
  echo "  --dry-run           Show what would be installed"
  echo "  --tags TAGS         Install specific components only"
  echo "  --skip-prereqs      Skip prerequisite installation"
  echo "  -h, --help          Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                  # Install everything (default)"
  echo "  $0 --minimal        # Install minimal profile"
  echo "  $0 --interactive    # Choose components"
  echo "  $0 --tags shell     # Install only shell config"
}

# Install prerequisites (Ansible, Homebrew on macOS)
install_prerequisites() {
  print_section "Prerequisites"

  local os=$(detect_os)

  # macOS: Install Homebrew if needed
  if [[ "$os" == "macOS" ]]; then
    if ! command_exists brew; then
      if run_task "Installing Homebrew..." /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Add brew to path for this session
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
      else
        error "Failed to install Homebrew"
        exit 1
      fi
    else
      success "Homebrew already installed"
    fi
  fi

  # Install Ansible if needed
  if ! command_exists ansible; then
    if [[ "$os" == "macOS" ]]; then
      run_task "Installing Ansible..." brew install ansible
    else
      run_task "Updating apt cache..." sudo apt update
      run_task "Installing Ansible..." sudo apt install -y ansible git
    fi
  else
    success "Ansible already installed"
  fi

  # Install gum for interactive mode (optional)
  if [[ "$INTERACTIVE" == "true" ]] && ! command_exists gum; then
    if [[ "$os" == "macOS" ]]; then
      run_task "Installing gum (for interactive mode)..." brew install gum
    else
      # Skip gum on Linux, use fallback
      info "Using text-based selection (gum not available)"
    fi
  fi
}

# Prompt for sudo password (Linux only)
prompt_sudo_password() {
  local os=$(detect_os)
  if [[ "$os" != "macOS" ]]; then
    echo ""
    echo -n "Enter sudo password: "
    read -s BECOME_PASS
    echo ""
    export ANSIBLE_BECOME_PASS="$BECOME_PASS"
  fi
}

# Run Ansible playbook for components
install_components() {
  local components=("$@")
  local total=${#components[@]}
  local current=0
  local failed=()

  print_section "Installing Components"

  # Build ansible command
  local playbook="$SCRIPT_DIR/playbook.yml"

  # Suppress Ansible output completely
  export ANSIBLE_STDOUT_CALLBACK=minimal
  export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
  export ANSIBLE_DISPLAY_OK_HOSTS=false
  export ANSIBLE_NOCOLOR=1
  export ANSIBLE_FORCE_COLOR=0
  export ANSIBLE_NOCOWS=1

  for component in "${components[@]}"; do
    ((current++))
    local progress="[$current/$total]"
    local message="$progress Installing $component..."

    if [[ "$DRY_RUN" == "true" ]]; then
      info "[DRY RUN] Would install: $component"
      continue
    fi

    log "Installing component: $component"

    if [[ "$VERBOSE" == "true" ]]; then
      echo -e "${BLUE}→${NC} $message"
      if ansible-playbook "$playbook" --tags "$component" "${EXTRA_ARGS[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        success "$component"
      else
        error "$component failed"
        failed+=("$component")
      fi
    else
      if run_with_spinner "$message" ansible-playbook "$playbook" --tags "$component" "${EXTRA_ARGS[@]}"; then
        success "$component"
      else
        error "$component failed (check $LOG_FILE)"
        failed+=("$component")
      fi
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo ""
    warn "Some components failed to install: ${failed[*]}"
    warn "Check the log file for details: $LOG_FILE"
    return 1
  fi
}

# Print installation summary
print_summary() {
  local components=("$@")
  local os=$(detect_os)
  local shell=$(detect_shell)

  print_completion

  # Capitalize shell name (bash 3.2 compatible)
  local shell_display
  if [[ "$shell" == "zsh" ]]; then
    shell_display="Zsh"
  else
    shell_display="Bash"
  fi

  echo ""
  echo -e "${BOLD}Installed:${NC}"
  for comp in "${components[@]}"; do
    case $comp in
      shell)     echo "  ✓ Shell       $shell_display with syntax highlighting" ;;
      cli-tools) echo "  ✓ CLI Tools   eza, bat, fzf, zoxide, ripgrep..." ;;
      tmux)      echo "  ✓ Tmux        Terminal multiplexer with plugins" ;;
      neovim)    echo "  ✓ Neovim      LazyVim with LSP" ;;
      git)       echo "  ✓ Git         GitHub CLI, git-delta" ;;
      docker)    echo "  ✓ Docker      Engine + Compose" ;;
      python)    echo "  ✓ Python      UV package manager" ;;
      nvidia)    echo "  ✓ NVIDIA      Drivers + Container Toolkit" ;;
    esac
  done

  echo ""
  echo -e "${BOLD}Next Steps:${NC}"
  if [[ "$os" == "macOS" ]]; then
    echo "  1. source ~/.zshrc"
  else
    echo "  1. source ~/.bashrc"
    if array_contains "docker" "${components[@]}"; then
      echo "  2. Log out and back in for Docker group"
    fi
  fi
  echo "  2. zhelp              Show all commands"
  echo "  3. zupdate            Update Zen in the future"
  echo ""

  if [[ -n "$LOG_FILE" ]]; then
    echo -e "${DIM}Log file: $LOG_FILE${NC}"
    echo ""
  fi
}

# Print what would be installed (dry run)
print_dry_run() {
  local components=("$@")

  print_section "Dry Run - Components to Install"

  for comp in "${components[@]}"; do
    echo -e "  ${CYAN}○${NC} $comp - $(get_component_desc $comp)"
  done

  echo ""
  info "Run without --dry-run to install"
}

# Main function
main() {
  local extra_args=()
  EXTRA_ARGS=()

  # Parse arguments
  parse_args "$@"

  # Initialize logging
  init_logging "$SCRIPT_DIR/logs"

  # Print banner
  print_banner

  # Show platform info
  local os=$(detect_os)
  local shell=$(detect_shell)
  echo -e "Platform:   ${BOLD}$os${NC} (${shell})"
  echo -e "Profile:    ${BOLD}$PROFILE${NC}"
  echo -e "Log file:   ${DIM}$LOG_FILE${NC}"
  log "Profile: $PROFILE"

  # Get components based on profile or interactive selection
  local components
  if [[ "$INTERACTIVE" == "true" ]]; then
    echo ""
    components=$(select_components_interactive)
    log "Interactive selection: $components"
  elif [[ -n "$TAGS" ]]; then
    components="$TAGS"
    log "Custom tags: $components"
  else
    components=$(get_profile_components "$PROFILE")
    log "Profile components: $components"
  fi

  # Filter for platform
  components=$(filter_components_for_platform $components)

  # Convert to array
  local comp_array=($components)

  echo -e "Components: ${BOLD}${comp_array[*]}${NC}"

  # Dry run: just show what would be installed
  if [[ "$DRY_RUN" == "true" ]]; then
    print_dry_run "${comp_array[@]}"
    exit 0
  fi

  # Check not running as root
  check_not_root

  # Install prerequisites
  if [[ "$SKIP_PREREQS" != "true" ]]; then
    install_prerequisites
  fi

  # Prompt for sudo password on Linux (before spinners start)
  prompt_sudo_password

  # Install components
  if install_components "${comp_array[@]}"; then
    print_summary "${comp_array[@]}"
    log "Installation completed successfully"
    exit 0
  else
    log "Installation completed with errors"
    exit 1
  fi
}

# Run main
main "$@"
