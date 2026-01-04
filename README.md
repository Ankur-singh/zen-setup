# 🧘 Zen - Complete Terminal Environment

A complete, opinionated terminal development environment for macOS and Linux, inspired by [Omakub](https://github.com/basecamp/omakub). This Ansible-based setup transforms a fresh system into a beautiful, modern, and productive terminal first development environment with a single command.

**Zen (全)** - meaning "complete" or "all" in Japanese - provides everything you need for a perfect terminal experience.

## 🎯 Features

### Core Components
- **Modern Shell**: Zsh (macOS) or Bash (Linux) with custom prompt, aliases, and helpful functions
- **CLI Tools**: eza, bat, fzf, zoxide, ripgrep, fd, lazygit, btop, fastfetch
- **Tmux**: Pre-configured with TPM (Tmux Plugin Manager) and sensible defaults
- **Neovim**: LazyVim configuration with LSP, treesitter, and modern plugins
- **Git**: GitHub CLI with useful aliases and configurations
- **Docker**: Full Docker setup with proper group management
- **Python**: UV package manager from Astral (fast, modern Python tooling)

### What Makes This Different
- ✅ **Works on macOS and Linux**: Single playbook, platform-aware
- ✅ **Remote VM support**: Deploy to multiple servers from inventory
- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Modular**: Use tags to install only what you need
- ✅ **Customizable**: Variables for easy configuration
- ✅ **Terminal-only**: No desktop apps, perfect for servers and SSH
- ✅ **Smart versioning**: Tries latest from GitHub, falls back to pinned versions on rate limits

## 📋 Prerequisites

### For Quick Install (bootstrap.sh or make)

**No prerequisites!** The bootstrap script automatically installs Ansible if needed.

**Note for Linux users:** You'll be prompted for your sudo password during installation (needed for package installation).


### For Manual Ansible Install (Optional)

Only needed if you want to run Ansible commands directly:

**macOS:**
```bash
brew install ansible
```

**Linux:**
```bash
sudo apt update && sudo apt install -y ansible git
```

### For Remote VMs
- SSH access with key-based authentication
- Sudo privileges on remote machine

## 🚀 Quick Start

**TL;DR - One-Liner Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
```

**Or clone and run manually:** Clone the repo and run `./bootstrap.sh` (or `make install`).

After installation, run `zhelp` to see all available commands.

### Option 1: One-Liner Install (Easiest) ⭐⭐⭐

Install everything with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
```

This automatically:
- Clones the repository to `~/.local/share/zen-setup`
- Installs Ansible if needed
- Runs the complete setup
- Shows retry command if anything fails

**Custom install location:**
```bash
ZEN_SETUP_DIR=~/projects/zen curl -fsSL https://raw.githubusercontent.com/Ankur-singh/zen-setup/main/install.sh | bash
```

**If installation fails:**
The installer will show you a retry command like:
```bash
bash ~/.local/share/zen-setup/bootstrap.sh
```

### Option 2: Bootstrap Script (Recommended) ⭐⭐

Clone first, then run - gives you a chance to customize:

```bash
# Clone the repository
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# (Optional) Customize variables
nvim vars/common.yml

# Run bootstrap - handles everything!
./bootstrap.sh
```

### Option 3: Makefile (Quick & Simple) ⭐

If you prefer make commands:

```bash
# Clone the repository
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# (Optional) Customize variables
nvim vars/common.yml

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

For more control or remote VMs:

**For local machine:**
```bash
# Install Ansible first if not already installed
# macOS: brew install ansible
# Linux: sudo apt install ansible

# Clone and run
git clone https://github.com/Ankur-singh/zen-setup.git ~/.local/share/zen-setup
cd ~/.local/share/zen-setup

# macOS
ansible-playbook playbook.yml

# Linux (will ask for sudo password)
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

### Customization (Optional)

Before running any installation method, you can customize settings in `vars/common.yml`:

```yaml
git_user_name: "Your Name"
git_user_email: "your@email.com"
python_version: "3.12"
install_docker: true
install_nvidia: false             # Set to true for GPU support (Linux only)
nvidia_install_method: auto       # 'auto' or 'manual'
use_starship_prompt: false        # Set to true for Starship
```

### Post-installation

**Restart your terminal** or run:
```bash
# macOS (zsh)
source ~/.zshrc

# Linux (bash)
source ~/.bashrc
```

**For Docker** (Linux only), you need to log out and back in, or run:
```bash
newgrp docker
```

**For Git**, configure your identity if not set in variables:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

**For GitHub CLI**, authenticate:
```bash
gh auth login
```

## 📚 What Gets Installed

### Shell Configuration
- Custom prompt with git integration (zsh on macOS, bash on Linux)
- Optional Starship prompt support (modern, fast, cross-shell prompt)
- 50+ useful aliases (shared between shells)
- 30+ helpful functions (shared between shells)
- Better readline configuration (inputrc for bash)
- Command-line productivity shortcuts

### Modern CLI Tools

| Tool | Purpose | Replaces |
|------|---------|----------|
| **eza** | Modern ls with icons | ls |
| **bat** | Syntax highlighting cat | cat |
| **fzf** | Fuzzy finder | grep/find |
| **zoxide** | Smart directory jumper | cd |
| **ripgrep** | Fast recursive search | grep |
| **fd** | Fast file finder | find |
| **lazygit** | Terminal UI for git | - |
| **lazydocker** | Terminal UI for docker | - |
| **btop** | Beautiful process monitor | top/htop |
| **fastfetch** | System info display | neofetch |

### Tmux Setup
- **Prefix**: `Ctrl-a` (instead of Ctrl-b)
- **Plugins**: 
  - TPM (Plugin Manager)
  - tmux-sensible
  - tmux-resurrect (save/restore sessions)
  - tmux-continuum (auto-save sessions)
  - tmux-yank (better copy/paste)
  - vim-tmux-navigator (seamless vim/tmux navigation)

**Key Bindings:**
- `Prefix + |` - Split horizontally
- `Prefix + -` - Split vertically
- `Prefix + r` - Reload config
- `Alt + Arrow` - Switch panes (no prefix needed!)
- `Shift + Arrow` - Switch windows (no prefix needed!)

### Neovim with LazyVim
- LSP support for multiple languages
- Treesitter for better syntax highlighting
- Auto-completion
- File explorer, fuzzy finder, git integration
- Beautiful UI with modern theme

**Key Bindings:**
- `Space` - Leader key (shows menu)
- `:Lazy` - Plugin manager
- `:Mason` - LSP/formatter installer

### Docker
- Docker Engine with BuildKit
- Docker Compose (v2)
- User added to docker group (no sudo needed)
- Log rotation configured

### NVIDIA GPU Support (Optional, Linux only)
- NVIDIA drivers (auto-detected or specific version)
- NVIDIA utilities (nvidia-settings, nvidia-prime)
- NVIDIA Container Toolkit (only installed if Docker is present)
- Docker configured with GPU runtime

### Python with UV
- UV package manager (100x faster than pip)
- Python 3.12 by default
- Virtualenv support

**Common commands:**
```bash
uv venv                 # Create virtual environment
uv pip install <pkg>    # Install package
uv pip list            # List installed packages
venv                   # Create and activate venv (alias)
```

## 🎨 Customization

### Adding Remote VMs

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

### Customizing Per-Host Variables

Create host-specific variable files:
```bash
mkdir host_vars
cat > host_vars/vm1.yml <<EOF
install_docker: false
python_version: "3.11"
EOF
```

### Skip Specific Roles

Use `--skip-tags`:
```bash
# Skip Docker installation
ansible-playbook playbook.yml --skip-tags docker

# Skip Neovim
ansible-playbook playbook.yml --skip-tags neovim
```

### Local Customizations

The shell RC file includes support for local, non-managed customizations:
```bash
# macOS (zsh)
nvim ~/.zshrc.local

# Linux (bash)
nvim ~/.bashrc.local
```

These files won't be overwritten by Ansible.

## 📖 Quick Reference

After installation, run `zhelp` for a complete command reference. Here are the most common commands:

### Common Aliases
```bash
ls, ll, lt    # Modern file listing with eza (icons, tree view)
cd            # Smart directory jumping with zoxide
..            # Go up one directory
g             # git
gs            # git status
gcm "msg"     # git commit -m
gp            # git push
lzg           # LazyGit (interactive git UI)
d             # docker
dc            # docker-compose
dps           # docker ps
lzd           # LazyDocker (interactive docker UI)
v, vim        # neovim
t             # tmux
ta            # tmux attach
```

### Tmux Quick Keys
- **Prefix**: `Ctrl-a` (not Ctrl-b)
- `Prefix + |` - Split window horizontally
- `Prefix + -` - Split window vertically
- `Prefix + r` - Reload tmux config
- `Alt + Arrow` - Switch panes (no prefix needed!)
- `Shift + Arrow` - Switch windows (no prefix needed!)

### Neovim Quick Keys
- `Space` - Leader key (opens command menu)
- `:Lazy` - Plugin manager
- `:Mason` - Install LSP servers, formatters, linters
- `Space + e` - File explorer (neo-tree)
- `Space + ff` - Find files (telescope)
- `Space + /` - Search in project

### Python with UV
```bash
# Create and activate virtual environment
uv venv
source .venv/bin/activate

# Or use the alias
venv  # creates and activates automatically

# Install packages
uv pip install requests flask pandas

# List installed packages
uv pip list

# Freeze requirements
uv pip freeze > requirements.txt
```

### NVIDIA GPU Support (Linux Only)

The NVIDIA role is now **separate from Docker** - you can install drivers independently, and the Container Toolkit will only be installed if Docker is present.

**Configuration in `vars/common.yml`:**

```yaml
install_nvidia: true                    # Enable NVIDIA support
nvidia_install_method: auto             # 'auto' or 'manual'
nvidia_driver_version: "580"            # Used when method is 'manual'
```

**Installation Methods:**
- **`auto` (recommended)**: Uses `ubuntu-drivers autoinstall` to detect and install the best driver
- **`manual`**: Installs specific driver version from graphics-drivers PPA

**What gets installed:**
1. **NVIDIA Drivers** (always installed if GPU detected)
   - Auto-detected or specified version
   - NVIDIA utilities (nvidia-settings, nvidia-prime)

2. **NVIDIA Container Toolkit** (only if Docker is installed)
   - Docker configured with NVIDIA runtime
   - Enables GPU access in containers

**Installation Options:**

```bash
# Option 1: Install NVIDIA only
make install-nvidia

# Option 2: Install with Ansible tags
ansible-playbook playbook.yml --tags nvidia --ask-become-pass

# Option 3: Install everything including NVIDIA
# Set install_nvidia: true in vars/common.yml first
./bootstrap.sh
```

**Important:** After NVIDIA driver installation, you MUST reboot before GPU will work!

**Usage (if Docker is installed):**
```bash
# After reboot, test GPU in Docker
docker run --rm --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi

# Docker Compose - runtime method:
services:
  myservice:
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all

# Or with deploy syntax:
services:
  myservice:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

## 🛡️ Backup & Cleanup

### What Gets Backed Up

The setup automatically backs up your existing configs before making changes:

- **`~/.bashrc`** → `~/.bashrc.backup.YYYYMMDD_HHMMSS`
- **`~/.zshrc`** → `~/.zshrc.backup.YYYYMMDD_HHMMSS`
- **`~/.tmux.conf`** → `~/.tmux.conf.backup.YYYYMMDD_HHMMSS`
- **`~/.config/nvim/`** → `~/.config/nvim.backup.YYYYMMDD_HHMMSS`
- **`~/.local/share/nvim/`** → `~/.local/share/nvim.backup.YYYYMMDD_HHMMSS`

### Restore From Backup

If you want to restore your old configuration:

```bash
# Example: restore zsh config
cp ~/.zshrc.backup.20260104_123045 ~/.zshrc
source ~/.zshrc
```

### Clean Up Old Backups

Over time, you may accumulate multiple backup files. Use `zcleanup` to remove them:

```bash
# Interactive - shows all backups and asks for confirmation
zcleanup

# Force delete without confirmation
zcleanup --force
```

**Example output:**
```
🔍 Finding backup files created by Zen...

📦 Found 5 backup(s):

  📄 ~/.bashrc.backup.20260101_120000 (4.2K)
  📄 ~/.zshrc.backup.20260101_120000 (5.1K)
  📄 ~/.tmux.conf.backup.20260101_120000 (1.3K)
  📁 ~/.config/nvim.backup.20260101_120000 (156K)
  📁 ~/.local/share/nvim.backup.20260101_120000 (89M)

🗑️  Delete all these backups? (y/N)
```

## 🔧 Troubleshooting

### Docker permission denied
**After installation, you need to log out and back in** for docker group membership to take effect.

Quick fix without logout:
```bash
newgrp docker
```

### Shell changes not applied
Reload your shell configuration:
```bash
# macOS (zsh)
source ~/.zshrc

# Linux (bash)
source ~/.bashrc
```

Or simply open a new terminal window.

### Neovim plugins not installed
LazyVim will auto-install plugins on first run. If they don't install:
```bash
nvim
# Then press: Space (leader key) → Lazy (plugin manager) → I (install)
```

### Ansible fails with "permission denied"
Make sure you have:
- Sudo privileges on the target machine
- Proper SSH key authentication for remote VMs
- Correct `ansible_user` in inventory.yml

### UV not found after installation
Make sure `~/.local/bin` is in your PATH:
```bash
echo $PATH | grep ".local/bin"

# If not, reload your shell:
# macOS: source ~/.zshrc
# Linux: source ~/.bashrc
```

### NVIDIA GPU not working in Docker
If you've enabled NVIDIA support:

1. **Check driver installation:**
```bash
nvidia-smi  # Should show your GPU
```

2. **If nvidia-smi fails:** You need to reboot after driver installation
```bash
sudo reboot
```

3. **Test Docker GPU access:**
```bash
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

4. **Check Docker configuration:**
```bash
cat /etc/docker/daemon.json  # Should contain nvidia runtime config
```

## 🔄 Updating

### Quick Update (Recommended)

Use the built-in `zupdate` command:

```bash
# Update everything
zupdate

# Update specific components only
zupdate shell              # Shell config only
zupdate cli-tools          # CLI tools only
zupdate "shell,cli-tools"  # Multiple components
```

The `zupdate` command automatically:
- Auto-detects Zen directory location
- Pulls latest changes from git
- **Stops if already up to date** (no unnecessary reinstalls)
- Runs the Ansible playbook only if there are updates
- Shows what was updated
- Prompts to reload your shell

**If you moved the repository or installed to a non-standard location:**

Use `zsetdir` to update the location:
```bash
# Show current Zen directory
zsetdir

# Set new location
zsetdir ~/projects/zen
```

The `zupdate` command automatically searches:
- `$ZEN_SETUP_DIR` (if set via `zsetdir`)
- `~/.local/share/zen-setup` (default installation location)

### Manual Update

```bash
cd ~/.local/share/zen-setup
git pull
ansible-playbook playbook.yml
```

The playbook is idempotent, so it's safe to run multiple times.

## 📂 Project Structure

```
zen-setup/
├── playbook.yml              # Main playbook
├── inventory.yml             # Hosts inventory
├── ansible.cfg              # Ansible configuration
├── vars/
│   ├── common.yml           # Common variables
│   ├── darwin.yml           # macOS-specific
│   └── debian.yml           # Linux-specific
├── docs/
│   ├── STARSHIP.md          # Starship prompt guide
│   └── VERSIONS.md          # Version management & GitHub rate limits
└── roles/
    ├── shell/               # Shell configuration
    ├── cli-tools/           # Modern CLI tools
    ├── tmux/                # Tmux setup
    ├── neovim/              # Neovim + LazyVim
    ├── git/                 # Git + GitHub CLI
    ├── docker/              # Docker Engine
    ├── nvidia/              # NVIDIA drivers + Container Toolkit (Linux)
    └── python/              # Python + UV
```

## 📝 License

MIT License - feel free to use and modify as needed.

## 🙏 Acknowledgments

- Inspired by [Omakub](https://github.com/basecamp/omakub) by DHH
- Built with [Ansible](https://www.ansible.com/)
- Uses [LazyVim](https://www.lazyvim.org/) for Neovim configuration
- Powered by modern CLI tools from the open-source community

---

**Happy coding!** 🚀

Run `zhelp` after installation to see all available commands.

