#!/bin/bash
# Zen - Utility functions for pretty output

# Colors (not exported to avoid conflicts with tools like gum)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Status indicators
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
skip() { echo -e "${DIM}○${NC} ${DIM}$1${NC}"; }

# Spinner animation
# Usage: run_with_spinner "Installing package..." command arg1 arg2
run_with_spinner() {
  local message=$1
  shift
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  local pid
  local exit_status

  # Disable job control messages
  set +m 2>/dev/null || true

  # Run command in background, suppress all output
  "$@" >> "${LOG_FILE:-/dev/null}" 2>&1 &
  pid=$!

  # Display spinner while command runs
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r\033[K${CYAN}${spin:i++%${#spin}:1}${NC} ${message}"
    sleep 0.1
  done

  # Clear the spinner line
  printf "\r\033[K"

  # Check exit status
  wait $pid 2>/dev/null
  exit_status=$?

  # Re-enable job control
  set -m 2>/dev/null || true

  return $exit_status
}

# Run command and show status
# Usage: run_task "Task description" command arg1 arg2
run_task() {
  local message=$1
  shift

  if [[ "${VERBOSE:-false}" == "true" ]]; then
    echo -e "${BLUE}→${NC} ${message}"
    "$@" 2>&1 | tee -a "${LOG_FILE:-/dev/null}"
    local status=$?
    if [[ $status -eq 0 ]]; then
      success "$message"
    else
      error "$message"
    fi
    return $status
  else
    run_with_spinner "$message" "$@"
    local status=$?
    if [[ $status -eq 0 ]]; then
      success "$message"
    else
      error "$message"
    fi
    return $status
  fi
}

# Print banner
print_banner() {
  echo -e "${CYAN}"
  cat << 'EOF'
 ______
|___  /
   / / ___ _ __
  / / / _ \ '_ \
 / /_|  __/ | | |
/_____\___|_| |_|
EOF
  echo -e "${NC}"
  echo -e "${DIM}Complete Terminal Environment${NC}"
  echo ""
}

# Print section header
print_section() {
  echo ""
  echo -e "${BOLD}$1${NC}"
  echo "─────────────────────────────────────"
}

# Print completion summary
print_completion() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ Installation Complete!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Note: detect_os and detect_shell are now in lib/platform.sh
# Keeping these here for backward compatibility with existing code
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

detect_shell() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "zsh"
  else
    echo "bash"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Log message to file
log() {
  if [[ -n "${LOG_FILE:-}" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
  fi
}

# Initialize logging
init_logging() {
  local log_dir="$1"
  mkdir -p "$log_dir"
  export LOG_FILE="${log_dir}/install-$(date +%Y%m%d_%H%M%S).log"
  log "Installation started"
  log "Platform: $(detect_os)"
  log "Shell: $(detect_shell)"
}

# Check if running as root (warn)
check_not_root() {
  if [[ $EUID -eq 0 ]]; then
    warn "Running as root is not recommended"
    warn "Some tools may not work correctly"
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
}

# Array contains helper
array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

# Check if running in interactive terminal
is_interactive_terminal() {
  [[ -t 0 ]] && [[ -r /dev/tty ]] && [[ -w /dev/tty ]]
}

# Simple yes/no prompt (default No)
# Usage: prompt_restart "Question text"
# Returns: 0 for yes, 1 for no
prompt_restart() {
  local question="$1"

  # Non-interactive: just echo and treat as No
  if ! is_interactive_terminal; then
    echo "$question"
    return 1
  fi

  # Interactive: prompt user
  read -p "$question (y/N) " -n 1 -r REPLY < /dev/tty
  echo

  # Check response (default No)
  [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
}
