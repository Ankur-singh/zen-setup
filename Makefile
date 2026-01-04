# Makefile for Terminal Setup

.PHONY: help install install-local install-remote check lint test tags

# Default target
help:
	@echo "Terminal Development Environment Setup"
	@echo ""
	@echo "Available targets:"
	@echo "  make install        - Install on localhost (default)"
	@echo "  make install-remote - Install on remote VMs"
	@echo "  make check          - Check Ansible connectivity"
	@echo "  make lint           - Lint Ansible playbooks"
	@echo "  make tags           - List available tags"
	@echo ""
	@echo "Selective installation:"
	@echo "  make install-shell  - Install only shell configuration"
	@echo "  make install-tools  - Install only CLI tools"
	@echo "  make install-tmux   - Install only tmux"
	@echo "  make install-nvim   - Install only neovim"
	@echo "  make install-docker - Install only docker"
	@echo "  make install-python - Install only python/UV"
	@echo "  make install-git    - Install only git"

# Install on local machine
install:
	@echo "🚀 Installing terminal setup on localhost..."
	ansible-playbook playbook.yml

install-local: install

# Install on remote VMs
install-remote:
	@echo "🚀 Installing terminal setup on remote VMs..."
	ansible-playbook -i inventory.yml playbook.yml --limit remote_vms

# Check connectivity
check:
	@echo "🔍 Checking Ansible connectivity..."
	ansible all -m ping

# Lint playbooks
lint:
	@echo "🔍 Linting Ansible playbooks..."
	ansible-lint playbook.yml || true
	yamllint . || true

# List available tags
tags:
	@echo "📋 Available tags:"
	@echo "  - shell"
	@echo "  - cli-tools"
	@echo "  - tmux"
	@echo "  - neovim"
	@echo "  - git"
	@echo "  - docker"
	@echo "  - python"
	@echo "  - core (shell, cli-tools, tmux, git)"

# Selective installations
install-shell:
	ansible-playbook playbook.yml --tags shell

install-tools:
	ansible-playbook playbook.yml --tags cli-tools

install-tmux:
	ansible-playbook playbook.yml --tags tmux

install-nvim:
	ansible-playbook playbook.yml --tags neovim

install-docker:
	ansible-playbook playbook.yml --tags docker

install-python:
	ansible-playbook playbook.yml --tags python

install-git:
	ansible-playbook playbook.yml --tags git

# Install core components only (no docker, no neovim)
install-core:
	ansible-playbook playbook.yml --tags core

