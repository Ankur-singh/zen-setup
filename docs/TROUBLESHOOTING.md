# Troubleshooting Guide

Common issues and their solutions.

## 🐳 Docker Issues

### Docker permission denied
**After installation, you need to log out and back in** for docker group membership to take effect.

Quick fix without logout:
```bash
newgrp docker
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

## 🐚 Shell Issues

### Shell changes not applied

Reload your shell configuration:
```bash
# macOS (zsh)
source ~/.zshrc

# Linux (bash)
source ~/.bashrc
```

Or simply open a new terminal window.

### `git_prompt:2: read-only variable: status` error on macOS

This should be fixed in the latest version. Update with:
```bash
zupdate
```

If still occurs, check that you have the latest `~/.zsh/prompt` file.

### Commands not found after installation

Make sure `~/.local/bin` is in your PATH:
```bash
echo $PATH | grep ".local/bin"

# If not found, reload your shell:
# macOS: source ~/.zshrc
# Linux: source ~/.bashrc
```

## 📝 Neovim Issues

### Neovim plugins not installed

LazyVim will auto-install plugins on first run. If they don't install:
```bash
nvim
# Then press: Space (leader key) → Lazy (plugin manager) → I (install)
```

### LSP servers not working

Install LSP servers using Mason:
```bash
nvim
# Press: Space → Mason → Install your desired LSP servers
```

## 🔧 Ansible Issues

### Ansible fails with "permission denied"

Make sure you have:
- Sudo privileges on the target machine
- Proper SSH key authentication for remote VMs
- Correct `ansible_user` in inventory.yml

### "local_bin_dir is undefined" error

This means variables aren't loading. Make sure you're running the full playbook or the pre_tasks are tagged with `always`.

Fixed in latest version - update with `zupdate`.

## 🐍 Python Issues

### UV not found after installation

Make sure `~/.local/bin` is in your PATH:
```bash
echo $PATH | grep ".local/bin"

# If not, reload your shell:
# macOS: source ~/.zshrc
# Linux: source ~/.bashrc
```

### Can't create virtual environment

Make sure UV is installed:
```bash
which uv
uv --version

# If not found, reinstall:
zupdate python
```

## 🔄 Update Issues

### `zupdate` can't find Zen directory

Set the directory location:
```bash
zsetdir ~/.local/share/zen-setup
```

Or wherever you installed Zen.

### Git pull fails during update

Check your git configuration:
```bash
cd ~/.local/share/zen-setup
git status
git remote -v
```

## 🎨 Prompt Issues

### Prompt looks broken or has weird characters

This usually means your terminal doesn't support the fonts/icons. Install a Nerd Font:

**macOS:**
```bash
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
```

Then set your terminal to use the Nerd Font.

### Starship prompt not working

Make sure Starship is installed:
```bash
which starship
starship --version
```

Check that `use_starship_prompt: true` in `vars/common.yml`.

## 🧹 Cleanup Issues

### `zcleanup` shows errors on macOS

This should be fixed in the latest version. The error was related to glob patterns in zsh.

Update with:
```bash
zupdate
```

## 🔍 Getting More Help

### Check Logs
```bash
# Ansible logs
cd ~/.local/share/zen-setup
ansible-playbook playbook.yml -vvv  # Verbose mode

# System logs (Linux)
journalctl -xe
```

### Verify Installation
```bash
# Check what's installed
which eza bat fzf zoxide rg fd lazygit nvim tmux

# Check versions
eza --version
nvim --version
tmux -V
```

### File an Issue

If you're still stuck, please file an issue on GitHub with:
- Your OS and version
- Error messages
- Steps to reproduce
- Output of `zhelp`

https://github.com/Ankur-singh/zen-setup/issues

