# Zen Setup Profiles

Zen Setup offers two installation profiles to match your needs: **core** (default) and **enhanced**.

> **Default Changed:** As of the latest version, **core** is now the default profile. This provides a safer, less invasive installation that only installs packages without modifying your shell configuration. Opt-in to enhanced with `--enhanced` for the full experience.

## Core vs Enhanced: The Difference

### Core Profile (Default)
**Philosophy**: Install all essential tools, but NO customizations

**What Gets Installed**:
- ✅ Core CLI tools: jq, htop, lazygit, lazydocker, tree, gum, gh
- ✅ tmux (package only)
- ✅ git + gh (packages only)
- ✅ Docker + Docker Compose
- ✅ Python + UV package manager
- ✅ NVIDIA drivers + CUDA + Container Toolkit (Debian/Ubuntu only, if GPU detected)

**What Does NOT Get Applied**:
- ❌ NO shell configuration (no aliases, no functions, no custom prompt)
- ❌ NO tmux configuration (no ~/.tmux.conf, no TPM, no plugins)
- ❌ NO git configuration (no aliases, no delta integration)
- ❌ NO fancy replacement tools (no eza, bat, fzf, zoxide, ripgrep, fd, btop, delta, fastfetch)

**Config Files Modified**: NONE

**Use Case**:
- Installing on servers where you want tools but not personal customizations
- Giving to other people who want packages without your config preferences
- Testing packages without config interference
- You prefer to configure your own shell environment

### Enhanced Profile
**Philosophy**: Complete personal setup with all customizations

**What Gets Installed**:
- ✅ Everything from core profile, PLUS:
- ✅ Shell plugins: ble.sh (Linux) or zsh plugins (macOS)
- ✅ Fancy CLI replacements:
  - eza (replaces ls)
  - bat (replaces cat)
  - fzf (fuzzy finder)
  - zoxide (smart cd)
  - ripgrep (fast grep)
  - fd (fast find)
  - btop (system monitor)
  - delta (beautiful git diffs)
  - fastfetch (system info)
  - mosh (mobile shell)
  - tldr (quick man pages)

**What Gets Applied**:
- ✅ Full shell configuration (~/.bashrc or ~/.zshrc)
  - Custom aliases (ll, ls → eza, cat → bat, etc.)
  - Useful functions (mkcd, search, extract, etc.)
  - Custom colorized prompt with git integration
- ✅ Tmux configuration (~/.tmux.conf)
  - TPM plugin manager
  - 5 plugins (tmux-sensible, tmux-resurrect, tmux-continuum, tmux-yank, vim-tmux-navigator)
  - Custom keybindings (prefix = Ctrl-Space)
  - Catppuccin colors
- ✅ Git configuration (~/.gitconfig)
  - Convenient aliases (st, co, br, lg, amend, etc.)
  - Delta integration for beautiful diffs
  - Sensible defaults

**Config Files Modified**:
- ~/.bashrc or ~/.zshrc
- ~/.tmux.conf
- ~/.gitconfig

**Use Case**:
- Your personal development machine
- Complete terminal experience with all the goodies
- Modern tools with opinionated configurations

---

## Installation

### Core Profile (Default)
```bash
./setup.sh            # Core is now the default
./setup.sh --core     # Explicit flag (optional)
```

### Enhanced Profile
```bash
./setup.sh --enhanced  # Opt-in to full experience
```

---

## Comparison Table

| Profile | Packages Installed | Customizations Applied |
|---------|-------------------|------------------------|
| **Core** (default) | cli-tools-core + tmux + git + docker + python + nvidia | NONE (vanilla packages) |
| **Enhanced** | core + cli-tools-enhanced (eza, bat, fzf, zoxide, etc.) | Shell + Tmux + Git configs |

**Core**: All the tools, none of the customizations (packages only)

**Enhanced**: All the tools + fancy replacements + full customizations (complete personal setup)

---

## What Each Profile Installs

### Core Profile Components

**CLI Tools (cli-tools-core)**:
- `jq` - JSON processor
- `htop` - Interactive process viewer
- `curl`, `wget` - HTTP clients
- `lazygit` - Terminal UI for git
- `lazydocker` - Terminal UI for docker
- `tree` - Directory tree viewer
- `gum` - Shell script styling

**Development Tools**:
- `git` + `gh` - Version control + GitHub CLI (packages only, NO aliases)
- `tmux` - Terminal multiplexer (package only, NO config)
- `docker` + `docker-compose` - Container platform
- `python` + `uv` - Python with fast package manager
- `nvidia` - NVIDIA drivers + CUDA + Container Toolkit (Debian/Ubuntu only, if GPU detected)

**NO Customizations**:
- Your shell remains untouched
- No ~/.tmux.conf created
- No git aliases added
- No fancy replacement tools installed

### Enhanced Profile Components

**Everything from Core PLUS:**

**Fancy CLI Replacements (cli-tools-enhanced)**:
- `eza` - Modern replacement for `ls` with colors and icons
- `bat` - Modern replacement for `cat` with syntax highlighting
- `fzf` - Fuzzy finder for interactive filtering
- `zoxide` - Smart `cd` replacement that learns your habits
- `ripgrep` - Blazingly fast search tool (replaces grep)
- `fd` - Modern `find` replacement
- `btop` - Beautiful system monitor
- `delta` - Beautiful git diffs with syntax highlighting
- `fastfetch` - Fast system info display
- `mosh` - Mobile shell (better than ssh over unreliable connections)
- `tldr` - Simplified, community-driven man pages

**Shell Customizations (shell module)**:
- Custom bashrc/zshrc with plugins
- Bash: `ble.sh` (syntax highlighting, autosuggestions)
- Zsh: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`
- Custom colorized prompt with git info
- Smart aliases using modern tools
- Useful shell functions
- FZF integration with bat and eza previews
- Zoxide integration for smart directory jumping
- Fastfetch welcome message

---

## Aliases Examples (Enhanced Only)

```bash
# Modern tool replacements
ls → eza --color=always --group-directories-first --icons
cat → bat --style=plain --paging=never
cd → zoxide (z command)

# Enhanced commands
ll    → eza -lah --color=always --group-directories-first --icons
tree  → eza --tree --color=always --icons
grep  → rg (ripgrep)
find  → fd
```

---

## Functions Examples (Enhanced Only)

```bash
mkcd dirname          # Create and cd into directory
search pattern        # Search using ripgrep with context
extract file.tar.gz   # Smart archive extraction
gcom "commit message" # Git add all + commit
gp                    # Git push
gs                    # Git status
```

---

## Upgrading from Core to Enhanced

You can upgrade from core to enhanced at any time:

```bash
# Start with core
./setup.sh

# Later, upgrade to enhanced
./setup.sh --enhanced
```

The enhanced installation will:
- Install additional packages (eza, bat, fzf, zoxide, ripgrep, fd, btop, delta, fastfetch, mosh, tldr)
- Apply shell configuration (aliases, functions, prompt)
- Create tmux configuration (~/.tmux.conf with TPM and plugins)
- Add git configuration (aliases, delta integration)

---

## Profile Persistence with zupdate

Your profile choice is automatically saved and respected by `zupdate`:

```bash
# Install with core profile
./setup.sh
cat ~/.local/share/zen-setup/.profile  # Shows: core

# Later run update - automatically uses core profile
zupdate  # Maintains core (no customizations applied)

# Install with enhanced profile
./setup.sh --enhanced
cat ~/.local/share/zen-setup/.profile  # Shows: enhanced

# Later run update - automatically uses enhanced profile
zupdate  # Maintains enhanced (customizations preserved)
```

Your profile preference is stored in `~/.local/share/zen-setup/.profile` so updates maintain your configuration choice. You can always change profiles by running setup again with a different flag.

---

## Testing Your Profile

### Verify Core Profile

After installing core profile, verify packages are installed but NO customizations applied:

```bash
# Packages ARE installed
which jq htop lazygit lazydocker tree gum gh
which git tmux docker python3 uv
nvidia-smi  # Should work if GPU present

# NO custom aliases (should show minimal/default aliases)
alias  # Should NOT show 'ls' → 'eza'

# NO custom functions (these should NOT exist)
type mkcd search extract gcom  # Should fail

# NO zen-setup customizations in shell config
grep -i "zen" ~/.bashrc 2>/dev/null || echo "No zen customizations (correct)"

# NO tmux config or plugins
test ! -f ~/.tmux.conf || ! grep "TPM" ~/.tmux.conf || echo "No tmux config (correct)"

# NO git aliases
! git config --global alias.st || echo "Git aliases found (incorrect for core)"

# Modern replacement tools should NOT exist
! which eza bat fzf zoxide rg fd btop delta fastfetch || echo "Fancy tools found (incorrect for core)"
```

### Verify Enhanced Profile

After installing enhanced profile:

```bash
# All packages installed (core + enhanced)
which jq htop lazygit lazydocker tree gum gh git tmux docker python3 uv
which eza bat fzf zoxide rg fd btop delta fastfetch mosh tldr

# Custom aliases work
alias ls   # Should show 'eza' alias
alias cat  # Should show 'bat' alias

# Custom functions exist
type mkcd search extract gcom  # Should succeed

# Zen customizations in shell config
grep "Zen Configuration" ~/.bashrc || grep "Zen Configuration" ~/.zshrc

# Tmux config with TPM
grep "TPM" ~/.tmux.conf

# Git aliases exist
git config --global alias.st  # Should return "status"
git config --global core.pager  # Should return "delta"

# FZF preview uses bat
echo $FZF_DEFAULT_OPTS | grep bat

# Custom prompt (colorized with git info)
echo $PS1  # Should show custom prompt
```

---

## Custom Component Selection

If neither profile fits your needs, install specific components:

```bash
./setup.sh --components cli-tools-core,git,tmux,docker
```

Available components:
- `shell` - Shell configuration (aliases, functions, prompts) - Enhanced only
- `cli-tools-core` - Essential CLI tools (jq, htop, lazygit, lazydocker, tree, gum, gh)
- `cli-tools-enhanced` - Fancy replacements (eza, bat, fzf, zoxide, ripgrep, fd, btop, delta, fastfetch, mosh, tldr)
- `git` - Git + GitHub CLI (config only in enhanced)
- `tmux` - Tmux terminal multiplexer (config only in enhanced)
- `docker` - Docker Engine + Compose
- `python` - Python + UV package manager
- `nvidia` - NVIDIA drivers + CUDA + Container Toolkit (Debian/Ubuntu only)

---

## Philosophy

**Core Profile:** "Give me the tools, I'll configure them myself"
- All essential packages installed (docker, nvidia, python, git, tmux, cli-tools)
- Zero configuration changes
- Zero assumptions about your preferences
- Tools without opinions
- Perfect for servers or sharing

**Enhanced Profile:** "Give me the full experience"
- All packages from core PLUS fancy replacements
- Opinionated but sensible defaults
- Modern tools with smart integrations
- Full shell, tmux, and git customizations
- Batteries included, ready to use

Choose the profile that matches your needs. Both are valid approaches to a productive terminal environment.
