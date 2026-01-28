#!/bin/bash
# modules/docker.sh - Docker installation module
# Installs Docker Desktop (macOS) or Docker Engine (Linux)

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"
source "$_MODULE_DIR/../lib/sudo.sh"

# Install Docker on macOS (Docker Desktop)
install_docker_macos() {
    if [[ -d "/Applications/Docker.app" ]]; then
        success "Docker Desktop already installed"
        return 0
    fi

    info "Installing Docker Desktop via Homebrew..."
    brew install --cask docker >>"$LOG_FILE" 2>&1 && \
        success "Docker Desktop installed" || \
        warn "Could not install Docker Desktop automatically"

    echo ""
    info "Docker Desktop Installation"
    echo ""
    echo "If automatic installation failed, download from:"
    echo "  https://www.docker.com/products/docker-desktop"
    echo ""
    echo "After installation:"
    echo "  1. Open Docker Desktop from Applications"
    echo "  2. Complete the setup wizard"
    echo "  3. Docker will be available in your terminal"
    echo ""
}

# Install Docker on Linux (Docker Engine)
install_docker_linux() {
    if command -v docker &>/dev/null; then
        success "Docker already installed"
        return 0
    fi

    info "Installing Docker Engine on Linux..."

    # Remove old Docker versions
    info "Removing old Docker versions (if any)..."
    run_sudo apt remove -y docker docker-engine docker.io containerd runc >>"$LOG_FILE" 2>&1 || true

    # Install prerequisites
    info "Installing prerequisites..."
    pkg_install ca-certificates curl gnupg lsb-release >>"$LOG_FILE" 2>&1

    # Add Docker GPG key
    info "Adding Docker GPG key..."
    run_sudo mkdir -p /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>>"$LOG_FILE" | \
            run_sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        run_sudo chmod a+r /etc/apt/keyrings/docker.gpg
        success "Added Docker GPG key"
    else
        skip "Docker GPG key already exists"
    fi

    # Add Docker repository
    info "Adding Docker repository..."
    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
        local arch=$(dpkg --print-architecture)
        local codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
        echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $codename stable" | \
            run_sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        success "Added Docker repository"
    else
        skip "Docker repository already exists"
    fi

    # Update apt cache
    info "Updating package cache..."
    run_sudo apt update >>"$LOG_FILE" 2>&1

    # Install Docker Engine
    info "Installing Docker Engine..."
    run_sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin >>"$LOG_FILE" 2>&1 && \
        success "Installed Docker Engine" || \
        error "Failed to install Docker Engine"

    # Start and enable Docker service
    info "Starting Docker service..."
    run_sudo systemctl start docker >>"$LOG_FILE" 2>&1
    run_sudo systemctl enable docker >>"$LOG_FILE" 2>&1
    success "Docker service started and enabled"

    # Add user to docker group
    local current_user=$(whoami)
    info "Adding user $current_user to docker group..."
    run_sudo usermod -aG docker "$current_user" >>"$LOG_FILE" 2>&1
    success "Added user to docker group"

    # Configure Docker daemon
    configure_docker_daemon
}

# Configure Docker daemon.json
configure_docker_daemon() {
    info "Configuring Docker daemon..."

    local daemon_config="/etc/docker/daemon.json"

    # Only create if it doesn't exist
    if [[ -f "$daemon_config" ]]; then
        skip "Docker daemon.json already exists"
        return 0
    fi

    # Create daemon.json with sensible defaults
    cat | run_sudo tee "$daemon_config" >/dev/null << 'DAEMON_JSON_EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "features": {
    "buildkit": true
  }
}
DAEMON_JSON_EOF

    # Restart Docker to apply changes
    run_sudo systemctl restart docker >>"$LOG_FILE" 2>&1
    success "Configured Docker daemon"
}

# Main installation function
install_docker() {
    print_section "🐳 Installing Docker"

    if is_macos; then
        install_docker_macos
    elif is_linux; then
        install_docker_linux
    else
        error "Unsupported platform"
        return 1
    fi

    echo ""
    info "Docker Installation Complete"
    echo ""

    if is_linux; then
        warn "IMPORTANT: You need to log out and log back in for docker group changes to take effect!"
        echo ""
        echo "Alternatively, run: newgrp docker"
        echo ""
    fi

    echo "Useful Docker commands:"
    echo "  docker --version          Show Docker version"
    echo "  docker ps                 List running containers"
    echo "  docker images             List images"
    echo "  docker compose up         Start services (new syntax)"
    echo ""

    if command -v lazydocker &>/dev/null; then
        echo "TIP: Use 'lazydocker' for a visual Docker interface!"
        echo ""
    fi

    success "Docker setup complete"
}

# Export the main function
export -f install_docker
