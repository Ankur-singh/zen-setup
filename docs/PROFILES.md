# Zen Setup Profiles

Zen Setup offers two installation profiles to match your needs: **core** (default) and **enhanced**.

> **Default Changed:** As of the latest version, **core** is now the default profile. This provides a safer, less invasive installation that only installs packages without modifying your shell configuration. Opt-in to enhanced with `--enhanced` for the full experience.

## Core Profile

**Philosophy:** Essential packages ONLY, zero configuration changes.

The core profile installs useful CLI tools without modifying your shell configuration. Your bashrc, zshrc, aliases, functions, and prompt remain untouched.

### What's Included

**Packages:**
- `jq` - JSON processor
- `htop` - Interactive process viewer
- `curl`, `wget` - HTTP clients
- `git` - Version control
- `gh` - GitHub CLI
- `tmux` - Terminal multiplexer (with custom config)
- `lazygit` - Terminal UI for git
- `lazydocker` - Terminal UI for docker
- `tree` - Directory tree viewer
- `gum` - Shell script styling
- `python` + `uv` - Python with fast package manager

**Configuration:**
- Custom tmux configuration (`.tmux.conf`)
- Custom git configuration (`.gitconfig`)
- **NO shell configuration changes**
- **NO aliases** (no `ls` → `eza`, `cat` → `bat`, etc.)
- **NO functions** (no `mkcd`, `search`, `extract`, etc.)
- **NO prompt customization**
- **NO bashrc/zshrc modifications**

### When to Use Core

- You want tools but prefer your own shell configuration
- You're installing on a server or shared environment
- You want minimal system changes
- You plan to customize your shell yourself
- You're testing Zen Setup before committing to full setup

### Installation

```bash
./setup.sh            # Core is now the default
./setup.sh --core     # Explicit flag (optional)
```

---

## Enhanced Profile

**Philosophy:** Complete terminal experience with modern tools and full shell customization.

The enhanced profile includes all core tools PLUS modern replacements and a fully customized shell environment with aliases, functions, and prompts.

### What's Included

**All Core Packages PLUS:**
- `eza` - Modern replacement for `ls`
- `bat` - Modern replacement for `cat`
- `fzf` - Fuzzy finder
- `zoxide` - Smart `cd` replacement
- `ripgrep` - Fast search tool
- `fd` - Modern `find` replacement
- `btop` - Modern system monitor
- `delta` - Beautiful git diffs
- `fastfetch` - System info display
- `mosh` - Mobile shell
- `tldr` - Simplified man pages
- `docker` - Container platform

**Full Shell Configuration:**
- Custom bashrc/zshrc with plugins
- Bash: `ble.sh` (syntax highlighting, autosuggestions)
- Zsh: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`
- Custom colorized prompt with git info
- Smart aliases using modern tools
- Useful shell functions
- FZF integration with bat and eza previews
- Zoxide integration for smart directory jumping
- Fastfetch welcome message

### Aliases Examples

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

### Functions Examples

```bash
mkcd dirname          # Create and cd into directory
search pattern        # Search using ripgrep with context
extract file.tar.gz   # Smart archive extraction
gcom "commit message" # Git add all + commit
gp                    # Git push
gs                    # Git status
```

### When to Use Enhanced

- You want the complete Zen experience
- You're setting up your personal development machine
- You want modern CLI tools with sensible defaults
- You appreciate batteries-included configurations
- You want a beautiful, productive terminal

### Installation

```bash
./setup.sh --enhanced  # Explicit flag required (not default anymore)
```

---

## Comparison Table

| Feature | Core | Enhanced |
|---------|------|----------|
| Essential CLI tools (jq, htop, tree, gum) | ✅ | ✅ |
| Git + GitHub CLI | ✅ | ✅ |
| Tmux with config | ✅ | ✅ |
| Lazygit, Lazydocker | ✅ | ✅ |
| Python + UV | ✅ | ✅ |
| Modern replacements (eza, bat, fzf, etc.) | ❌ | ✅ |
| Docker | ❌ | ✅ |
| Shell configuration | ❌ | ✅ |
| Aliases | ❌ | ✅ |
| Functions | ❌ | ✅ |
| Custom prompt | ❌ | ✅ |
| Bashrc/Zshrc modifications | ❌ | ✅ |

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
- Install additional packages (eza, bat, fzf, etc.)
- Apply shell configuration
- Add aliases, functions, and prompts
- Configure modern tool integrations

## Profile Persistence with zupdate

Your profile choice is automatically saved and respected by `zupdate`:

```bash
# Install with core profile
./setup.sh

# Later run update - automatically uses core profile
zupdate

# Install with enhanced profile
./setup.sh --enhanced

# Later run update - automatically uses enhanced profile
zupdate
```

Your profile preference is stored in `~/.local/share/zen-setup/.profile` so updates maintain your configuration choice. You can always change profiles by running setup again with a different flag.

---

## Custom Component Selection

If neither profile fits your needs, install specific components:

```bash
./setup.sh --components cli-tools-core,git,tmux
```

Available components:
- `shell` - Shell configuration (aliases, functions, prompts)
- `cli-tools-core` - Essential CLI tools
- `cli-tools-enhanced` - Modern tool replacements + extras
- `git` - Git + GitHub CLI
- `tmux` - Tmux terminal multiplexer
- `docker` - Docker Engine + Compose
- `python` - Python + UV package manager
- `nvidia` - NVIDIA drivers (Linux only)

---

## Testing Your Profile

### Verify Core Profile

After installing core profile, verify it's truly minimal:

```bash
# NO custom aliases (should show minimal/default aliases)
alias

# NO custom functions (these should NOT exist)
type mkcd search extract gcom

# NO custom prompt (should be system default)
echo $PS1

# NO zen-setup customizations in bashrc/zshrc
grep -i "zen" ~/.bashrc
grep -i "zen" ~/.zshrc

# But tools ARE installed
which jq htop lazygit gh

# Modern tools should NOT exist
which eza bat fzf zoxide  # Should fail
```

### Verify Enhanced Profile

After installing enhanced profile:

```bash
# Custom aliases work
alias ls  # Should show 'eza' alias
alias cat # Should show 'bat' alias

# Custom functions exist
type mkcd search extract

# Custom prompt is active (colorized with git info)
echo $PS1

# Modern tools installed
which eza bat fzf zoxide ripgrep fd btop

# FZF preview uses bat
echo $FZF_DEFAULT_OPTS | grep bat

# Fastfetch runs on shell start
fastfetch
```

---

## Philosophy

**Core Profile:** "Give me the tools, I'll configure them myself"
- Respects your existing shell setup
- Zero assumptions about your preferences
- Tools without opinions

**Enhanced Profile:** "Give me the full experience"
- Opinionated but sensible defaults
- Modern tools with smart integrations
- Batteries included, ready to use

Choose the profile that matches your needs. Both are valid approaches to a productive terminal environment.
