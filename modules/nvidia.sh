#!/bin/bash
# modules/nvidia.sh - NVIDIA GPU support module
# Installs NVIDIA drivers, CUDA toolkit, and Container Toolkit (Linux only)

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"
source "$_MODULE_DIR/../lib/sudo.sh"

# Detect NVIDIA GPU
detect_nvidia_gpu() {
    if ! has_nvidia_gpu; then
        skip "No NVIDIA GPU detected - skipping NVIDIA installation"
        return 1
    fi

    info "NVIDIA GPU detected:"
    lspci | grep -i nvidia | while read -r line; do
        echo "  $line"
    done
    echo ""

    return 0
}

# Check if NVIDIA driver is already installed
check_nvidia_driver() {
    if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
        success "NVIDIA driver already installed and active"
        nvidia-smi 2>>"$LOG_FILE" | head -10
        return 0
    fi
    return 1
}

# Install NVIDIA driver using ubuntu-drivers auto
install_nvidia_driver_auto() {
    info "Installing NVIDIA drivers using ubuntu-drivers (auto)..."

    # Install ubuntu-drivers-common
    pkg_install ubuntu-drivers-common >>"$LOG_FILE" 2>&1

    # Auto-install recommended drivers
    run_sudo ubuntu-drivers autoinstall >>"$LOG_FILE" 2>&1 && \
        success "NVIDIA drivers installed" || \
        error "Failed to install NVIDIA drivers"
}

# Install specific NVIDIA driver version
install_nvidia_driver_manual() {
    local version="${1:-580}"

    info "Installing NVIDIA driver version $version..."

    # Add graphics-drivers PPA
    info "Adding graphics-drivers PPA..."
    run_sudo add-apt-repository -y ppa:graphics-drivers/ppa >>"$LOG_FILE" 2>&1
    run_sudo apt update >>"$LOG_FILE" 2>&1

    # Install specific driver version
    pkg_install "nvidia-driver-$version" >>"$LOG_FILE" 2>&1 && \
        success "NVIDIA driver $version installed" || \
        error "Failed to install NVIDIA driver $version"
}

# Install NVIDIA utilities and CUDA
install_nvidia_utilities() {
    info "Installing NVIDIA utilities and CUDA toolkit..."

    local packages=(
        "nvidia-settings"
        "nvidia-prime"
        "nvidia-cuda-toolkit"
    )

    pkg_install "${packages[@]}" >>"$LOG_FILE" 2>&1 && \
        success "Installed NVIDIA utilities and CUDA" || \
        error "Failed to install NVIDIA utilities"
}

# Install NVIDIA Container Toolkit
install_nvidia_container_toolkit() {
    # Check if Docker is installed
    if ! command -v docker &>/dev/null; then
        skip "Docker not installed - skipping Container Toolkit"
        return 0
    fi

    # Check if NVIDIA driver is active
    if ! nvidia-smi &>/dev/null; then
        warn "NVIDIA driver not active (reboot required)"
        warn "Skipping Container Toolkit installation"
        warn "Re-run setup after reboot to install Container Toolkit"
        return 0
    fi

    info "Installing NVIDIA Container Toolkit..."

    # Install prerequisites
    pkg_install curl gnupg >>"$LOG_FILE" 2>&1

    # Create keyrings directory
    run_sudo mkdir -p /etc/apt/keyrings

    # Add GPG key
    if [[ ! -f /etc/apt/keyrings/nvidia-container-toolkit.gpg ]]; then
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey 2>>"$LOG_FILE" | \
            run_sudo gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
        run_sudo chmod a+r /etc/apt/keyrings/nvidia-container-toolkit.gpg
    fi

    # Add repository
    if [[ ! -f /etc/apt/sources.list.d/nvidia-container-toolkit.list ]]; then
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list 2>>"$LOG_FILE" | \
            sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#g' | \
            run_sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
    fi

    # Update and install
    run_sudo apt update >>"$LOG_FILE" 2>&1
    pkg_install nvidia-container-toolkit >>"$LOG_FILE" 2>&1 && \
        success "Installed NVIDIA Container Toolkit" || \
        error "Failed to install NVIDIA Container Toolkit"

    # Configure Docker runtime
    info "Configuring Docker to use NVIDIA runtime..."
    run_sudo nvidia-ctk runtime configure --runtime=docker >>"$LOG_FILE" 2>&1 && \
        success "Configured Docker for NVIDIA runtime" || \
        error "Failed to configure Docker runtime"

    # Restart Docker
    run_sudo systemctl restart docker >>"$LOG_FILE" 2>&1 && \
        success "Restarted Docker" || \
        warn "Failed to restart Docker"
}

# Print post-installation message
print_nvidia_message() {
    local driver_active=false

    if nvidia-smi &>/dev/null; then
        driver_active=true
    fi

    echo ""
    info "NVIDIA Installation Complete"
    echo ""

    if $driver_active; then
        echo "✅ NVIDIA driver is active!"
        echo ""
        nvidia-smi 2>>"$LOG_FILE" | head -15
        echo ""

        if command -v nvcc &>/dev/null; then
            echo "✅ CUDA Toolkit installed!"
            nvcc --version | head -4
            echo ""
        fi

        if command -v nvidia-ctk &>/dev/null; then
            echo "✅ NVIDIA Container Toolkit installed!"
            echo ""
            echo "Test GPU access in Docker:"
            echo "  docker run --rm --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi"
            echo ""
        fi
    else
        warn "⚠️  NVIDIA driver installed but requires REBOOT to activate"
        echo ""
        echo "Next steps:"
        echo "  1. Reboot your system: sudo reboot"
        echo "  2. After reboot, verify with: nvidia-smi"
        echo "  3. Verify CUDA with: nvcc --version"
        if command -v docker &>/dev/null; then
            echo "  4. Re-run setup to install Container Toolkit"
        fi
        echo ""
    fi
}

# Main installation function
install_nvidia() {
    print_section "🎮 Installing NVIDIA GPU Support"

    # Skip if not Linux
    if ! is_linux; then
        skip "NVIDIA installation is Linux-only"
        return 0
    fi

    # Detect GPU
    if ! detect_nvidia_gpu; then
        return 0
    fi

    # Check if already installed
    if check_nvidia_driver; then
        # Driver is active, proceed to container toolkit
        install_nvidia_container_toolkit
        print_nvidia_message
        return 0
    fi

    # Install driver (auto method by default)
    install_nvidia_driver_auto

    # Install utilities and CUDA
    install_nvidia_utilities

    # Try to install container toolkit (will skip if driver not active)
    install_nvidia_container_toolkit

    # Print status
    print_nvidia_message

    success "NVIDIA installation complete"
}

# Export the main function
export -f install_nvidia
