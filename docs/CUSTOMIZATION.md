# Customization Guide

How to customize Zen for your needs.

## 📝 Variables

### Common Variables (`vars/common.yml`)

```yaml
# Git configuration
git_user_name: "Your Name"
git_user_email: "your@email.com"

# Python configuration
python_version: "3.12"

# Feature flags
install_docker: true
install_nvidia: false             # Set to true for GPU support (Linux only)
nvidia_install_method: auto       # 'auto' or 'manual'
nvidia_driver_version: "580"      # Used when method is 'manual'

# Optional tools
install_lazygit: true
install_lazydocker: true
install_btop: true
install_fastfetch: true

# Prompt configuration
use_starship_prompt: false        # Set to true for Starship

# Neovim configuration
neovim_config_type: lazyvim       # Options: lazyvim, kickstart, minimal
```

## 🏷️ Using Tags

Install only specific components:

```bash
# Only shell and CLI tools
ansible-playbook playbook.yml --tags "shell,cli-tools"

# Only Docker
ansible-playbook playbook.yml --tags docker

# Skip specific components
ansible-playbook playbook.yml --skip-tags "docker,neovim"

# Core components only (shell, cli-tools, tmux, git)
ansible-playbook playbook.yml --tags core
```

### Available Tags

- `shell` - Shell configuration
- `cli-tools` - Modern CLI tools
- `tmux` - Tmux setup
- `neovim` / `editor` - Neovim with LazyVim
- `git` - Git + GitHub CLI
- `docker` - Docker Engine + Compose
- `nvidia` / `gpu` - NVIDIA drivers + Container Toolkit (Linux)
- `python` / `languages` - Python + UV
- `core` - Essential components (shell, cli-tools, tmux, git)

## 🔧 Per-Host Variables

Create host-specific variable files:

```bash
mkdir host_vars
cat > host_vars/vm1.yml <<EOF
install_docker: false
python_version: "3.11"
use_starship_prompt: true
EOF
```

## 🎨 Local Customizations

Add your own customizations without Ansible managing them:

### macOS (zsh)
```bash
nvim ~/.zshrc.local
```

### Linux (bash)
```bash
nvim ~/.bashrc.local
```

These files are sourced by the main RC file but won't be overwritten by Zen updates.

### Example Local Customizations

```bash
# ~/.zshrc.local or ~/.bashrc.local

# Custom aliases
alias myproject='cd ~/projects/myproject'

# Custom environment variables
export MY_API_KEY="secret"

# Custom functions
myfunction() {
  echo "My custom function"
}

# Override Zen settings
export EDITOR=vim  # Instead of nvim
```

## 🎨 Prompt Customization

### Using Starship

Set in `vars/common.yml`:
```yaml
use_starship_prompt: true
```

Then customize Starship:
```bash
nvim ~/.config/starship.toml
```

See [STARSHIP.md](STARSHIP.md) for details.

### Using Custom Prompt

The default custom prompt shows:
- Username@hostname
- Current directory
- Git branch and status
- Python virtualenv
- Exit code (if non-zero)

Edit the prompt file:
```bash
# macOS
nvim ~/.zsh/prompt

# Linux
nvim ~/.bash/prompt
```

## 🔌 Adding More Tools

### Add APT Packages (Linux)

Edit `vars/debian.yml`:
```yaml
apt_packages:
  - curl
  - wget
  # ... existing packages ...
  - your-package-here
```

### Add Homebrew Packages (macOS)

Edit `vars/darwin.yml` or install manually:
```bash
brew install your-package
```

### Add Custom Scripts

Place scripts in `~/.local/bin/` (already in PATH):
```bash
nvim ~/.local/bin/myscript
chmod +x ~/.local/bin/myscript
```

## 🔄 Updating Customizations

After modifying `vars/` files, re-run:
```bash
zupdate
# or
cd ~/.local/share/zen-setup && ansible-playbook playbook.yml
```

