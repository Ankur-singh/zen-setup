# Starship Prompt Guide

## What is Starship?

[Starship](https://starship.rs/) is a minimal, blazing-fast, and infinitely customizable prompt for any shell. It's written in Rust and provides:

- ⚡ **Fast**: Written in Rust, it's incredibly fast
- 🎨 **Customizable**: Every aspect is configurable
- 🔀 **Cross-shell**: Works with bash, zsh, fish, PowerShell, and more
- 📦 **Smart**: Shows relevant information based on your context
- 🎯 **Git-aware**: Rich git status information
- 🐍 **Language-aware**: Detects Python, Node.js, Rust, Go, and more

## Enabling Starship

Starship is **optional** in this setup. To enable it:

### Option 1: Before Installation

Edit `vars/common.yml`:
```yaml
use_starship_prompt: true
```

Then run the playbook:
```bash
ansible-playbook playbook.yml
```

### Option 2: After Installation

Edit `vars/common.yml`:
```yaml
use_starship_prompt: true
```

Then re-run the shell role:
```bash
ansible-playbook playbook.yml --tags shell
```

Restart your terminal:
```bash
# macOS
source ~/.zshrc

# Linux
source ~/.bashrc
```

## Configuration

Starship configuration is stored in `~/.config/starship.toml`.

### Default Configuration

The default setup includes:
- Username and hostname display
- Current directory (truncated)
- Git branch and status
- Python virtualenv indicator
- Node.js, Go, Rust version detection
- Docker context indicator
- Command duration for long-running commands

### Customizing Your Prompt

Edit the configuration:
```bash
nvim ~/.config/starship.toml
```

#### Example Customizations

**Minimal Prompt:**
```toml
format = "$directory$git_branch$character"
```

**Add Time:**
```toml
[time]
disabled = false
format = '🕙[\[ $time \]]($style) '
```

**Change Colors:**
```toml
[directory]
style = "bold yellow"

[git_branch]
style = "bold green"
```

**Add More Language Support:**
```toml
[ruby]
symbol = " "
detect_extensions = ["rb"]
```

### Preset Configurations

Starship provides several presets. To use one:

```bash
# View available presets
starship preset --list

# Apply a preset (e.g., nerd-font-symbols)
starship preset nerd-font-symbols -o ~/.config/starship.toml
```

Popular presets:
- `nerd-font-symbols` - Use Nerd Font symbols
- `pure-preset` - Minimalist prompt
- `pastel-powerline` - Powerline-style with pastel colors
- `tokyo-night` - Tokyo Night theme

## Features

### Git Integration

Shows:
- Current branch
- Number of modified files
- Staged files
- Untracked files
- Ahead/behind remote
- Merge conflicts

### Language Detection

Automatically detects and shows versions for:
- Python (with virtualenv support)
- Node.js
- Go
- Rust
- Ruby
- Java
- And many more

### Smart Context

Shows relevant information only when needed:
- Docker context (only when in project with Dockerfile)
- Package version (only in package directories)
- Kubernetes context (only when kubectl config exists)

## Performance

Starship is extremely fast:
- Written in Rust for maximum performance
- Parallel module execution
- Lazy loading of module information
- Caching of expensive operations

Typical prompt render time: **< 10ms**

## Switching Back to Custom Prompt

To switch back to the custom prompt:

1. Edit `vars/common.yml`:
```yaml
use_starship_prompt: false
```

2. Re-run the playbook:
```bash
ansible-playbook playbook.yml --tags shell
```

3. Restart your terminal

## Comparison: Custom vs Starship

| Feature | Custom Prompt | Starship |
|---------|---------------|----------|
| **Speed** | Fast | Blazing fast |
| **Git Status** | Basic (clean/dirty) | Detailed (files, branch, remote) |
| **Language Detection** | Manual | Automatic |
| **Customization** | Edit shell files | Edit TOML config |
| **Cross-shell** | Bash/Zsh only | All shells |
| **Themes** | Custom coded | Presets available |
| **Dependencies** | None | Starship binary |
| **File Size** | ~1KB | ~10MB binary |

## Troubleshooting

### Starship Not Found

Check installation:
```bash
which starship

# macOS
brew list starship

# Linux
ls -la /usr/local/bin/starship
```

### Icons Not Showing

Install a Nerd Font:
```bash
# Already installed by this playbook
# Meslo LG Nerd Font
# Fira Code Nerd Font
```

Set your terminal to use a Nerd Font:
- iTerm2: Preferences → Profiles → Text → Font
- Terminal.app: Preferences → Profiles → Text → Font

### Prompt Too Slow

Disable expensive modules in `~/.config/starship.toml`:
```toml
[package]
disabled = true

[kubernetes]
disabled = true
```

### Wrong Shell Detection

Force shell initialization:
```bash
# Add to your RC file
eval "$(starship init bash)"  # or zsh
```

## Resources

- **Official Docs**: https://starship.rs/
- **Configuration**: https://starship.rs/config/
- **Presets**: https://starship.rs/presets/
- **GitHub**: https://github.com/starship/starship

## Examples

### What You'll See

**In a Git Repository:**
```
╭─user@hostname in ~/project on  main !1 ?2 
╰─❯
```

**With Python Virtualenv:**
```
╭─user@hostname in ~/project via  3.12.0 (.venv)
╰─❯
```

**After Long Command:**
```
╭─user@hostname in ~/project took 5s
╰─❯
```

**With Error:**
```
╭─user@hostname in ~/project
╰─❯ (in red)
```

## Summary

Starship provides a modern, feature-rich prompt experience with:
- ✅ Automatic language/tool detection
- ✅ Rich git status
- ✅ Fast performance
- ✅ Easy customization
- ✅ Cross-shell compatibility
- ✅ Beautiful defaults

Enable it by setting `use_starship_prompt: true` in `vars/common.yml`!

