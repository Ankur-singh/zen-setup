# 🧘 Zen Features Reference

Quick overview of what's included in Zen - your complete terminal environment.

**Zen (全)** - meaning "complete" or "all" in Japanese - provides everything you need for terminal perfection.

> **Quick Links:**
> - [Installation Guide](docs/INSTALLATION.md)
> - [Commands Reference](docs/COMMANDS.md)
> - [Customization](docs/CUSTOMIZATION.md)
> - [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🛠️ Core Components

**Shell** (platform-native)
- **macOS**: Zsh with autosuggestions, syntax-highlighting, completions
- **Linux**: Bash with ble.sh (autosuggestions, syntax-highlighting)
- Optional Starship prompt support
- 50+ aliases, 30+ functions (shared across platforms)


**CLI Tools** (15+ modern utilities)

| Tool | Purpose |
|------|---------|
| eza | Modern ls with icons |
| bat | Better cat with syntax highlighting |
| fzf | Fuzzy finder |
| zoxide | Smart cd (learns your patterns) |
| ripgrep | Fast recursive grep |
| fd | Fast find alternative |
| lazygit | Terminal UI for git |
| lazydocker | Terminal UI for docker |
| btop | Beautiful process monitor |
| fastfetch | System info display |
| git-delta | Beautiful git diffs |
| lumen | AI-powered diff tool *(macOS only)* |
| jq, tree, tldr | Common utilities |

**Tmux**
- TPM (Plugin Manager) + 6 plugins
- Custom keybindings (Ctrl-a prefix)
- Session save/restore (resurrect + continuum)
- Catppuccin status bar

**Neovim**
- LazyVim configuration
- LSP, treesitter, auto-completion
- File explorer, fuzzy finder, git integration

**Development**
- Docker Engine + Compose (user in docker group)
- Python 3.12 + UV package manager
- Git + GitHub CLI

**GPU Support (Optional, Linux only)**
- NVIDIA drivers (auto-detected or manual version)
- NVIDIA CUDA Toolkit (compiler and libraries)
- NVIDIA utilities (nvidia-settings, nvidia-prime)
- NVIDIA Container Toolkit (if Docker installed)
- Separate role, independent from Docker

## 🌐 Platform Support

| Platform | Shell | Package Manager | Docker |
|----------|-------|-----------------|--------|
| macOS | Zsh | Homebrew | Desktop |
| Linux | Bash | APT | Engine |
| Remote VMs | Bash | APT | Engine |

### Platform-Specific Features

| Feature | macOS | Linux |
|---------|:-----:|:-----:|
| Zsh + plugins (autosuggestions, syntax-highlighting) | Yes | - |
| Bash + ble.sh (autosuggestions, syntax-highlighting) | - | Yes |
| git-delta (beautiful diffs) | Yes | Yes |
| lumen (AI-powered diffs) | Yes | - |
| NVIDIA GPU support | - | Yes |

**Requirements:**
- macOS 10.15+ or Ubuntu 20.04+ / Debian 11+
- SSH access for remote VMs
- Sudo privileges for package installation

## 🎯 Use Cases

This setup is ideal for:

✅ **Remote servers & VMs** - Terminal-only, no GUI needed  
✅ **Multiple machines** - Deploy to many systems via Ansible  
✅ **macOS + Linux** - Single playbook for both platforms  
✅ **SSH-only access** - Perfect for headless systems  
✅ **Python development** - UV, virtualenv, modern tooling  
✅ **Tmux users** - Full configuration with plugins  
✅ **Terminal-centric workflow** - No desktop apps, pure CLI  

## ⚙️ Ansible Features

- **Idempotent**: Safe to run multiple times
- **Modular**: 8 roles, install selectively with tags
- **Backup**: Existing dotfiles backed up automatically
- **Platform-aware**: Detects OS, installs appropriate packages
- **Inventory**: Manage multiple remote hosts
- **Variables**: Host-specific and global configuration
- **Smart dependencies**: NVIDIA Container Toolkit only installs if Docker present

## 🔮 Future Enhancements

Potential additions:

- [ ] Node.js, Ruby, Go, Rust support
- [ ] Alternative version managers (asdf, mise)
- [x] Zsh support for macOS ✅
- [x] Starship prompt ✅


## 💡 Customization

Easily customize via variables in `vars/common.yml`:

| Setting | Description |
|---------|-------------|
| `use_starship_prompt` | Use Starship instead of custom prompt |
| `install_nvidia` | Enable NVIDIA GPU support *(Linux only)* |
| `install_blesh` | Enable ble.sh for bash *(Linux only)* |
| `install_lazygit` | Install lazygit TUI |
| `install_lazydocker` | Install lazydocker TUI |
| `install_btop` | Install btop system monitor |
| `python_version` | Python version to install (default: 3.12) |
