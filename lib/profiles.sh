#!/bin/bash
# Zen - Installation profiles (bash 3.2 compatible)

# Profile definitions
# Each profile is a space-separated list of component tags

# Core: Shell essentials only (no docker, no replacement tools)
PROFILE_CORE="shell cli-tools-core tmux git python"

# Enhanced: Full development setup (default)
PROFILE_ENHANCED="shell cli-tools-enhanced tmux git docker python"

# Get components for a profile
get_profile_components() {
  local profile="$1"
  case "$profile" in
    core) echo "$PROFILE_CORE" ;;
    *)    echo "$PROFILE_ENHANCED" ;;
  esac
}

# Get component description
get_component_desc() {
  case "$1" in
    shell)               echo "Shell configuration (zsh/bash with plugins)" ;;
    cli-tools-core)      echo "Core CLI tools (lazygit, lazydocker, jq, htop, tree, gum)" ;;
    cli-tools-enhanced)  echo "Enhanced CLI tools (core + eza, bat, fzf, zoxide, ripgrep, fd, btop, mosh, tldr, delta)" ;;
    tmux)                echo "Tmux terminal multiplexer" ;;
    git)                 echo "Git + GitHub CLI" ;;
    docker)              echo "Docker Engine + Compose" ;;
    python)              echo "Python + UV package manager" ;;
    nvidia)              echo "NVIDIA drivers + Container Toolkit (Linux only)" ;;
    *)                   echo "Unknown component" ;;
  esac
}

# Get all available components
get_all_components() {
  echo "shell cli-tools-core cli-tools-enhanced tmux git docker python nvidia"
}

# Filter components based on platform
filter_components_for_platform() {
  local os
  os=$(detect_os)
  local result=""

  for component in "$@"; do
    # nvidia is Linux only
    if [[ "$component" == "nvidia" ]] && [[ "$os" == "macOS" ]]; then
      continue
    fi
    result="$result $component"
  done

  echo "$result" | xargs
}

# Interactive component selection using gum or fallback
select_components_interactive() {
  local available
  available=$(filter_components_for_platform $(get_all_components))

  if command_exists gum; then
    # Use gum for pretty TUI selection
    local selected
    selected=$(gum choose --no-limit \
      --header "Select components to install:" \
      --selected="shell,cli-tools-core,tmux,git,python" \
      $available)
    echo "$selected" | tr '\n' ' '
  elif command_exists fzf; then
    # Fallback to fzf
    local selected
    selected=$(echo "$available" | tr ' ' '\n' | \
      fzf --multi --prompt="Select components (TAB to toggle): " \
          --header="Press TAB to select, ENTER when done")
    echo "$selected" | tr '\n' ' '
  else
    # Simple text prompt fallback
    echo ""
    echo "Available components:"
    for comp in $available; do
      echo "  - $comp: $(get_component_desc $comp)"
    done
    echo ""
    echo "Enter components to install (space separated):"
    echo "Default: shell cli-tools-core tmux git python"
    read -r user_input < /dev/tty
    if [[ -z "$user_input" ]]; then
      echo "shell cli-tools-core tmux git python"
    else
      echo "$user_input"
    fi
  fi
}

# Print profile info
print_profile_info() {
  local profile="$1"
  local components
  components=$(get_profile_components "$profile")

  echo -e "${BOLD}Profile: ${CYAN}$profile${NC}"
  echo ""
  echo "Components:"
  for comp in $components; do
    echo -e "  ${GREEN}✓${NC} $comp - $(get_component_desc $comp)"
  done
}
