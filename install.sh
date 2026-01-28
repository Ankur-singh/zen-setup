#!/bin/bash
# One-liner installer for Zen - Complete Terminal Environment
# Usage: curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
#
# Options (passed to setup.sh):
#   --core              Core profile - essential tools only, no docker (cli-tools-core, git, tmux, python)
#   --components LIST   Install specific components
#   -v, --verbose       Show detailed output
#   -h, --help          Show help

set -e

REPO_URL="https://github.com/Ankur-singh/zen-setup.git"
INSTALL_DIR="${ZEN_SETUP_DIR:-$HOME/.local/share/zen-setup}"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Show help and exit if requested
for arg in "$@"; do
  if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
    echo "Zen - Complete Terminal Environment"
    echo ""
    echo "Usage: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash -s -- [OPTIONS]"
    echo ""
    echo "Profiles:"
    echo "  (default)       Enhanced - all enhancements: shell + cli-tools-enhanced + custom configs + docker"
    echo "  --core          Core - essential tools only: cli-tools-core, no docker, no replacements"
    echo ""
    echo "Options:"
    echo "  --components    Install specific components (comma-separated)"
    echo "                  Available: shell,cli-tools-core,cli-tools-enhanced,git,tmux,docker,python,nvidia"
    echo "  -v, --verbose   Show detailed output"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  curl ... | bash                                # Install enhanced profile (default)"
    echo "  curl ... | bash -s -- --core                   # Install core profile (essential tools only)"
    echo "  curl ... | bash -s -- --components shell,cli-tools-core,git   # Install specific components"
    exit 0
  fi
done

# Print banner
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

echo -e "Installing to: ${BOLD}$INSTALL_DIR${NC}"
echo ""

# Ensure parent directory exists
mkdir -p "$(dirname "$INSTALL_DIR")"

# Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Directory already exists${NC}"
  if [ -n "$ZSH_VERSION" ]; then
    echo -n "Update existing installation? (y/N) "
    read -r REPLY < /dev/tty
  else
    read -p "Update existing installation? (y/N) " -n 1 -r REPLY < /dev/tty
    echo
  fi
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$INSTALL_DIR"
    echo -e "${CYAN}Pulling latest changes...${NC}"
    if ! git pull; then
      echo ""
      echo -e "${RED}Git pull failed!${NC}"
      echo -e "You can retry by running: ${DIM}bash $INSTALL_DIR/setup.sh${NC}"
      exit 1
    fi
  else
    echo -e "${RED}Installation cancelled${NC}"
    exit 1
  fi
else
  echo -e "${CYAN}Cloning repository...${NC}"
  if ! git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo ""
    echo -e "${RED}Git clone failed!${NC}"
    echo -e "Please check your internet connection and try again."
    exit 1
  fi
  cd "$INSTALL_DIR"
fi

echo ""

# Run setup with all arguments
if ! bash "$INSTALL_DIR/setup.sh" "$@"; then
  echo ""
  echo -e "${RED}Installation failed!${NC}"
  echo -e "Check the log file in ${DIM}$HOME/.local/share/zen-setup/logs/${NC}"
  echo -e "Retry with: ${DIM}bash $INSTALL_DIR/setup.sh${NC}"
  exit 1
fi
