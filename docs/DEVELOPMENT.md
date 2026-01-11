# Development Guide

This guide is for developers and contributors who want to understand the internals of Zen, debug issues, or contribute new features.

## Project Structure

```
zen-setup/
├── bootstrap.sh          # Main installer with pretty output
├── install.sh            # One-liner installer (curl | bash)
├── playbook.yml          # Main Ansible playbook
├── ansible.cfg           # Ansible configuration
├── Makefile              # Development shortcuts
├── lib/
│   ├── utils.sh          # Shared utility functions (colors, spinners)
│   └── profiles.sh       # Installation profiles
├── bin/
│   ├── zsetup            # Wrapper to run setup from anywhere
│   └── zdoctor           # Health check utility
├── roles/
│   ├── shell/            # Shell configuration (zsh/bash)
│   ├── cli-tools/        # CLI tools (eza, bat, fzf, etc.)
│   ├── tmux/             # Tmux configuration
│   ├── neovim/           # Neovim with LazyVim
│   ├── git/              # Git + GitHub CLI
│   ├── docker/           # Docker Engine + Compose
│   ├── python/           # Python + UV
│   └── nvidia/           # NVIDIA drivers (Linux only)
├── vars/
│   ├── common.yml        # Shared variables
│   ├── darwin.yml        # macOS-specific packages
│   ├── debian.yml        # Debian/Ubuntu packages
│   └── example-local.yml # Template for local overrides
├── docs/
│   ├── INSTALLATION.md   # Installation guide
│   ├── COMMANDS.md       # Command reference
│   ├── CUSTOMIZATION.md  # Customization guide
│   ├── TROUBLESHOOTING.md # Troubleshooting guide
│   └── DEVELOPMENT.md    # This file
└── logs/                 # Installation logs (gitignored)
```

## Running Ansible Manually

For debugging or development, you can run Ansible directly instead of using `bootstrap.sh`.

### Full Installation

```bash
# macOS (no sudo needed)
ansible-playbook playbook.yml

# Linux (needs sudo for apt)
ansible-playbook playbook.yml --ask-become-pass
```

### Install Specific Components

Use tags to install only specific components:

```bash
# Single component
ansible-playbook playbook.yml --tags shell
ansible-playbook playbook.yml --tags cli-tools
ansible-playbook playbook.yml --tags tmux

# Multiple components
ansible-playbook playbook.yml --tags "shell,cli-tools,tmux"

# All available tags:
# shell, cli-tools, tmux, neovim, git, docker, python, nvidia
```

### Check Mode (Dry Run)

See what would change without making changes:

```bash
ansible-playbook playbook.yml --check --diff
```

### Verbose Output

For debugging, add `-v`, `-vv`, or `-vvv` for more detail:

```bash
ansible-playbook playbook.yml -vv
```

## Makefile Commands

The Makefile provides shortcuts for common operations:

```bash
# Show available commands
make help

# Install everything
make install

# Install specific tags
make shell
make cli-tools
make tmux
make neovim

# Development commands
make lint          # Check Ansible syntax
make check         # Dry run
make list-tags     # Show available tags
make list-tasks    # Show all tasks
```

## Adding a New Tool

1. **Decide which role** the tool belongs to (or create a new role)

2. **Add to vars files:**
   - `vars/darwin.yml` - Add to `homebrew_packages` list
   - `vars/debian.yml` - Add to `apt_packages` or `install_from_source`
   - `vars/common.yml` - Add version if installing from source

3. **Add installation task** (for source installs on Linux):
   ```yaml
   - name: Install mytool
     block:
       - name: Try to get latest mytool version from GitHub
         uri:
           url: https://api.github.com/repos/owner/mytool/releases/latest
           return_content: yes
           timeout: 10
         register: mytool_latest_check
         failed_when: false
         changed_when: false

       - name: Set mytool version (latest or fallback)
         set_fact:
           mytool_version: "{{ mytool_latest_check.json.tag_name | regex_replace('^v', '') if mytool_latest_check.status == 200 else tool_versions.mytool }}"

       - name: Download and install mytool
         shell: |
           # Installation commands here
         args:
           executable: /bin/bash
           creates: /usr/bin/mytool
         become: yes
   ```

4. **Add aliases/functions** if needed:
   - `roles/shell/files/bash_aliases`
   - `roles/shell/files/bash_functions`

5. **Update documentation:**
   - `docs/COMMANDS.md`
   - `roles/shell/files/zhelp`

## Testing Changes

### Local Testing

```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run to see what would change
ansible-playbook playbook.yml --check --diff --tags your-tag

# Run with verbose output
ansible-playbook playbook.yml --tags your-tag -vv
```

### Testing on Remote Machines

Create an inventory file:

```ini
# inventory/hosts.ini
[remote]
server1 ansible_host=192.168.1.100 ansible_user=ubuntu
server2 ansible_host=192.168.1.101 ansible_user=ubuntu
```

Run on remote:

```bash
ansible-playbook playbook.yml -i inventory/hosts.ini --ask-become-pass
```

## Debugging Tips

### Check Ansible Facts

See what Ansible knows about the system:

```bash
ansible localhost -m setup
```

### List All Variables

```bash
ansible-playbook playbook.yml --extra-vars "debug=true" -e @vars/common.yml -e @vars/darwin.yml
```

### Check Task Results

Add `register` and `debug` to tasks:

```yaml
- name: Install something
  shell: some command
  register: result

- name: Show result
  debug:
    var: result
```

### Common Issues

1. **GitHub API rate limit** - Tools fall back to `tool_versions` in common.yml
2. **Permission denied** - Check `become: yes` for apt/dpkg commands
3. **Command not found** - Ensure `creates:` path is correct

## Code Style

- Use 2-space indentation in YAML
- Use descriptive task names
- Add comments for complex logic
- Use `| default(value)` for optional variables
- Use blocks for related tasks
- Always add `creates:` for idempotency

## Release Process

1. Update version numbers in `vars/common.yml`
2. Test on fresh macOS and Ubuntu VMs
3. Update CHANGELOG.md
4. Tag the release: `git tag v1.x.x`
5. Push: `git push origin main --tags`
