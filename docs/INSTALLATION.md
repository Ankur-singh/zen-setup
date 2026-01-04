# Installation Guide

Complete installation guide for Zen.

## 🚀 Installation Methods

### Option 1: One-Liner Install (Easiest)

```bash
curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
```

**What it does:**
- Clones the repository to `~/.local/share/zen-setup`
- Installs Ansible if needed
- Runs the complete setup
- Shows retry command if anything fails

**Custom install location:**
```bash
ZEN_SETUP_DIR=~/projects/zen curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
```

### Option 2: Clone First (Customizable)

```bash
# Clone the repository
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# (Optional) Customize variables
nvim vars/common.yml

# Run bootstrap
./bootstrap.sh
```

### Option 3: Using Makefile

```bash
# Clone the repository
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# Install everything
make install

# Or install specific components
make install-shell    # Shell only
make install-tools    # CLI tools only
make install-tmux     # Tmux only
make install-nvim     # Neovim only
make install-docker   # Docker only
make install-nvidia   # NVIDIA drivers + Container Toolkit (Linux only)
make install-python   # Python + UV only
```

### Option 4: Manual Ansible (Advanced)

**macOS:**
```bash
brew install ansible
```

**Linux:**
```bash
sudo apt update && sudo apt install -y ansible git
```


**For local machine:**
```bash
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# macOS
ansible-playbook playbook.yml

# Linux
ansible-playbook playbook.yml --ask-become-pass
```

**For remote VMs:**
```bash
# Add your VMs to inventory.yml
nvim inventory.yml

# Run against remote hosts
ansible-playbook playbook.yml --limit remote_vms

# Or specific host
ansible-playbook playbook.yml --limit vm1
```

**Selective installation with tags:**
```bash
# Only shell and CLI tools
ansible-playbook playbook.yml --tags "shell,cli-tools"

# Install NVIDIA drivers + Container Toolkit (Linux only)
ansible-playbook playbook.yml --tags "nvidia" --ask-become-pass

# Skip Docker
ansible-playbook playbook.yml --skip-tags "docker"
```

## 📝 Post-Installation

### Restart Your Terminal

```bash
# macOS (zsh)
source ~/.zshrc

# Linux (bash)
source ~/.bashrc
```

Or simply open a new terminal window.

### Docker Setup (Linux only)

You need to log out and back in for docker group membership to take effect.

Quick fix without logout:
```bash
newgrp docker
```

### Git Configuration

Configure your identity if not set in variables:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### GitHub CLI

Authenticate with GitHub:
```bash
gh auth login
```

### First Commands

Try these after installation:
```bash
zhelp      # See all available commands
lzg        # LazyGit - visual git interface
ff         # Fuzzy find files with preview
nvim       # Open Neovim with LazyVim
btop       # Beautiful system monitor
```

## 🔄 Remote VM Setup

### Adding VMs to Inventory

Edit `inventory.yml`:
```yaml
remote_vms:
  hosts:
    vm1:
      ansible_host: 192.168.1.100
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
    vm2:
      ansible_host: 192.168.1.101
      ansible_user: admin
```

### Deploy to Remote Hosts

```bash
# Deploy to all remote VMs
ansible-playbook playbook.yml --limit remote_vms

# Deploy to specific host
ansible-playbook playbook.yml --limit vm1

# Deploy specific components only
ansible-playbook playbook.yml --limit vm1 --tags "shell,cli-tools"
```

## 🎨 Customization

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for detailed customization options.

