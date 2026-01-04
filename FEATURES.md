# Features Reference

Quick overview of what's included in this terminal setup.

> For installation details, see [README.md](README.md)

## 🛠️ Core Components

**Shell**
- Zsh (macOS) or Bash (Linux)
- Starship prompt support
- 50+ aliases, 30+ functions


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
- NVIDIA utilities (nvidia-settings, nvidia-prime)
- NVIDIA Container Toolkit (if Docker installed)
- Separate role, independent from Docker

## 🌐 Platform Support

| Platform | Shell | Package Manager | Docker |
|----------|-------|-----------------|--------|
| macOS | Zsh | Homebrew | Desktop |
| Linux | Bash | APT | Engine |
| Remote VMs | ✅ | ✅ | ✅ |

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

Easily customize via variables:

1. **Shell**: Override default shell per platform
2. **Prompt**: Switch between custom and Starship
3. **Tools**: Enable/disable optional tools
4. **Languages**: Extend Python role for other languages
5. **Theme**: Modify tmux/neovim colors
6. **Versions**: Pin specific tool versions
