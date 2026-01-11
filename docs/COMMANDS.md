# Command Reference

Complete reference for all commands available in Zen.

> **Tip:** Run `zhelp` in your terminal for a quick reference.

## 🧘 Zen Commands

### `zhelp`
Show quick command reference.

```bash
zhelp
```

### `zsetup [options]`
Run Zen setup with options.

```bash
# Full setup (default)
zsetup

# Minimal setup (no neovim, docker)
zsetup --minimal

# Interactive mode - choose components
zsetup --interactive

# Preview what will be installed
zsetup --dry-run

# Verbose output
zsetup --verbose
```

### `zdoctor`
Health check your Zen installation.

```bash
# Check all tools and configurations
zdoctor

# Show help
zdoctor --help
```

**What it checks:**
- Core tools (git, ansible, homebrew)
- CLI tools (eza, bat, fzf, etc.)
- Development tools (neovim, tmux, python, docker)
- Shell configuration (rc file, plugins)
- Tmux configuration (plugins, config)
- Neovim configuration (LazyVim)
- Zen installation status

### `zupdate [tags]`
Update Zen from the repository.

```bash
# Update everything
zupdate

# Update specific components
zupdate shell
zupdate cli-tools
zupdate "shell,cli-tools"
```

**What it does:**
- Auto-detects Zen directory
- Pulls latest changes from git
- Stops if already up to date
- Runs Ansible playbook with changes
- Shows what was updated

### `zsetdir [path]`
Set or show Zen directory location.

```bash
# Show current location
zsetdir

# Set new location
zsetdir ~/projects/zen-setup
```

### `zcleanup [--force]`
Clean up backup files created by Zen.

```bash
# Interactive (asks for confirmation)
zcleanup

# Force delete without asking
zcleanup --force
```

## 📁 Navigation & Files

### File Listing
```bash
ls          # Modern ls with eza (icons, colors)
lsa         # List all files (including hidden)
ll          # Detailed list view
lt          # Tree view (level 2)
lta         # Tree view with hidden files
tree        # Full tree view
```

### Navigation
```bash
cd <dir>    # Smart cd with zoxide (learns your patterns)
..          # Go up one directory
...         # Go up two directories
....        # Go up three directories
z <name>    # Jump to frequently used directory
```

### File Operations
```bash
mkcd <dir>  # Create directory and cd into it
backup <f>  # Backup file with timestamp
extract <f> # Extract any archive type
compress <f> # Create tar.gz archive
```

### Finding Files
```bash
ff          # Fuzzy file finder with preview
findf <pat> # Find files by pattern
findd <pat> # Find directories by pattern
search <txt> # Search text in files (ripgrep)
count [dir] # Count files in directory
```

## 🔀 Git Shortcuts

### Basic Commands
```bash
g           # git
gs          # git status
ga          # git add
gc          # git commit
gcm "msg"   # git commit -m "message"
gca         # git commit --amend
gcam "msg"  # git commit -a -m "message"
```

### Advanced Git
```bash
gp          # git push
gpl         # git pull
gd          # git diff (uses git-delta for beautiful output)
gds         # git diff --staged (with git-delta)
gco         # git checkout
gb          # git branch
gl          # git log (pretty)
gla         # git log --all (pretty)
```

**Note:** `git diff` automatically uses git-delta for syntax-highlighted, side-by-side diffs.

### Git Functions
```bash
gcl <url>   # Clone repo and cd into it
gnb <name>  # Create new branch and switch
gcom <type> # Conventional commit (e.g., gcom feat "add feature")
gchanged    # Show files changed in last commit
gundo       # Undo last commit (keep changes)
lzg         # LazyGit (interactive git UI)
```

## 🐳 Docker Commands

### Basic Docker
```bash
d           # docker
dc          # docker-compose
dps         # docker ps
dpsa        # docker ps -a
di          # docker images
dex         # docker exec -it
dlogs       # docker logs -f
```

### Docker Functions
```bash
denter <id>        # Enter running container (bash or sh)
docker-cleanup     # Clean up all docker resources
docker-rm-stopped  # Remove stopped containers
docker-rm-images   # Remove dangling images
lzd                # LazyDocker (interactive docker UI)
```

## 🐍 Python Commands

### Basic Python
```bash
py          # python3
uv          # UV package manager
```

### Virtual Environments
```bash
venv        # Create venv with UV and activate
uv-init     # Create venv and activate
uv-activate # Activate existing venv

# Manual usage
uv venv
source .venv/bin/activate
```

### Package Management
```bash
uv pip install <pkg>  # Install package
uv pip list           # List packages
uv pip freeze         # Freeze requirements
```

## 📺 Tmux Commands

### Basic Tmux
```bash
t           # tmux
ta          # tmux attach
tn <name>   # Create NEW named session (always creates)
tm [name]   # Smart attach (tries to attach first, creates if needed)
```

**Difference:** `tm` is smart (attaches if exists), `tn` always creates new.

### Tmux Key Bindings

**Prefix:** `Ctrl-a`

```bash
Prefix + |        # Split horizontally
Prefix + -        # Split vertically
Prefix + r        # Reload config
Alt + Arrow       # Switch panes (no prefix!)
Shift + Arrow     # Switch windows (no prefix!)
```

## ✏️ Editor Commands

```bash
v           # nvim
vim         # nvim
n           # nvim . (open current directory)
```

### Neovim Key Bindings
```bash
Space       # Leader key (shows command menu)
:Lazy       # Plugin manager
:Mason      # Install LSP servers, formatters
Space + e   # File explorer
Space + ff  # Find files
Space + /   # Search in project
```

## 🖥️ System Commands

### Monitoring
```bash
top         # btop (beautiful process monitor)
disk        # Show disk usage (df -h)
duh         # Disk usage sorted (current directory)
meminfo     # Show memory info
```

### Network
```bash
myip        # Show public IP (copies to clipboard)
localip     # Show local IP (copies to clipboard)
ports       # Show open ports
```

### Process Management
```bash
killp <name> # Kill process by name
j            # jobs -l
```

## 🛠️ Utility Functions

### Information
```bash
weather [loc] # Check weather
cheat <cmd>   # Show cheatsheet for command
hgrep <text>  # Search command history
```

### Quick Tools
```bash
serve [port]  # Start HTTP server (default: 8000)
genpass [len] # Generate random password
note [text]   # Quick notes (saves to ~/.notes/YYYY-MM-DD.md)
              # Usage: note "text" OR note (opens editor)
```

### System
```bash
c           # clear
h           # history
path        # Show PATH (one per line)
now         # Current time
today       # Current date
week        # Week number
reload      # Reload shell configuration
```

## 🎨 Customization Commands

```bash
aliases     # Edit aliases in editor
functions   # Edit functions in editor
editrc      # Edit RC file and reload
tmuxconf    # Edit tmux.conf
```

## 📊 Full Alias List

Run `alias` to see all active aliases, or check:
- `~/.zsh/aliases` (macOS)
- `~/.bash/aliases` (Linux)

## 📚 Full Function List

Check the source:
- `~/.zsh/functions` (macOS)
- `~/.bash/functions` (Linux)

Or run `type <function-name>` to see what a function does.

