# Zen Setup - Profile System Documentation

## CRITICAL: Understanding Core vs Enhanced Profiles

**DO NOT** make the mistake of thinking profiles differ by WHICH packages to install.
**The profiles differ by WHETHER customizations are applied.**

### Core Profile
- **Installs**: ALL essential packages
  - cli-tools-core (jq, htop, lazygit, lazydocker, tree, gum, gh)
  - tmux (package only)
  - git + gh (packages only)
  - docker + docker compose
  - python + uv
  - nvidia (drivers + CUDA + container toolkit) on Debian/Ubuntu Linux only if GPU detected

- **Does NOT Install**:
  - Fancy replacement tools (eza, bat, fzf, zoxide, ripgrep, fd, btop, delta, fastfetch)

- **Does NOT Apply**:
  - Shell configuration (no ~/.bashrc modifications, no aliases, no functions, no prompts)
  - Tmux configuration (no ~/.tmux.conf, no TPM, no plugins)
  - Git configuration (no aliases, no delta integration)

- **Purpose**: For servers or sharing with others who want packages without your personal customizations

### Enhanced Profile
- **Installs**: Everything from core PLUS:
  - cli-tools-enhanced (eza, bat, fzf, zoxide, ripgrep, fd, btop, delta, fastfetch, mosh, tldr)
  - Shell plugins (ble.sh on Linux, zsh plugins on macOS)

- **Applies**: All customizations
  - Shell: ~/.bashrc or ~/.zshrc with aliases, functions, custom prompt
  - Tmux: ~/.tmux.conf with TPM, plugins, custom keybindings
  - Git: ~/.gitconfig with aliases, delta integration

- **Purpose**: Personal development setup with all the goodies

## Module Behavior

### Modules That Must Check PROFILE:
1. **modules/shell.sh** ✅ Already has profile check
2. **modules/tmux.sh** ✅ Has profile check (install package always, skip config in core)
3. **modules/git.sh** ✅ Has profile check (install package always, skip config in core)

### Modules That Don't Need Profile Checks:
- **modules/cli-tools-core.sh** - Only installs packages, no configs
- **modules/cli-tools-enhanced.sh** - Only in enhanced profile anyway
- **modules/docker.sh** - Only installs packages, minimal config (daemon.json is not personal customization)
- **modules/python.sh** - Only installs packages, no personal configs
- **modules/nvidia.sh** - Only installs drivers, no personal configs (Debian/Ubuntu Linux only)

## Profile Persistence

The chosen profile is saved to `~/.local/share/zen-setup/.profile` and used by `zupdate`.

- User installs with `--core` → saves "core" → `zupdate` maintains core
- User installs with `--enhanced` → saves "enhanced" → `zupdate` maintains enhanced
- User can switch profiles anytime by running setup again with different flag

## NVIDIA Support

NVIDIA is **Debian/Ubuntu Linux only** and automatically:
- Skipped on macOS (not supported)
- Skipped on non-Debian/Ubuntu Linux distributions
- Skipped if no GPU detected
- Included in both core and enhanced profiles (when applicable)
