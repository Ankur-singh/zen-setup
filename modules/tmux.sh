#!/bin/bash
# modules/tmux.sh - Tmux configuration module
# Installs tmux with TPM (Tmux Plugin Manager) and plugins

_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MODULE_DIR/../lib/utils.sh"
source "$_MODULE_DIR/../lib/platform.sh"

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        success "TPM already installed"
        return 0
    fi

    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir" >>"$LOG_FILE" 2>&1 && \
        success "Installed TPM" || \
        error "Failed to install TPM"
}

# Create tmux.conf with TPM and plugins
create_tmux_config() {
    local tmux_conf="$HOME/.tmux.conf"

    info "Creating tmux configuration..."

    cat > "$tmux_conf" << 'TMUX_CONF_EOF'
# Modern Tmux Configuration (Zen Setup)
# Prefix: Ctrl-Space (instead of Ctrl-b)

# ============================================
# General Settings
# ============================================

# Change prefix from Ctrl-b to Ctrl-Space
unbind C-b
set-option -g prefix C-Space
bind-key C-Space send-prefix

# Enable true color support
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Enable mouse support
set -g mouse on

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer size
set -g history-limit 50000

# Display messages for 4 seconds
set -g display-time 4000

# Refresh status line every 5 seconds
set -g status-interval 5

# Focus events enabled for terminals that support them
set -g focus-events on

# Super useful when using "grouped sessions" and multi-monitor setup
setw -g aggressive-resize on

# Don't rename windows automatically
set -g allow-rename off

# Enable vi mode
setw -g mode-keys vi

# ============================================
# Key Bindings
# ============================================

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Split panes using | and - (more intuitive)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Switch windows using Shift-arrow without prefix
bind -n S-Left previous-window
bind -n S-Right next-window

# Pane navigation using prefix + hjkl
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes using prefix + HJKL (capital letters)
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Vi-style copy mode
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"

# macOS clipboard support (pbcopy)
if-shell "uname | grep -q Darwin" {
    bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
    bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
}

# Quick window selection
bind -r C-h select-window -t :-
bind -r C-l select-window -t :+

# Create new window in current path
bind c new-window -c "#{pane_current_path}"

# ============================================
# Status Bar (Catppuccin-inspired)
# ============================================

# Status bar positioning
set -g status-position bottom
set -g status-justify left

# Status bar styling
set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
set -g status-left-length 100
set -g status-right-length 100

# Left side: session name with prefix indicator
set -g status-left '#[bg=#{?client_prefix,#f38ba8,#89b4fa},fg=#1e1e2e,bold] #{?client_prefix,PREFIX,#S} #[bg=#1e1e2e,fg=default] '

# Right side: date and time
set -g status-right '#[bg=#1e1e2e]#[fg=#f38ba8] %Y-%m-%d #[fg=#89b4fa] %H:%M '

# Window status
setw -g window-status-format '#[fg=#6c7086] #I:#W '
setw -g window-status-current-format '#[bg=#89b4fa,fg=#1e1e2e,bold] #I:#W '

# Pane border
set -g pane-border-style 'fg=#313244'
set -g pane-active-border-style 'fg=#89b4fa'

# Message style
set -g message-style 'bg=#89b4fa fg=#1e1e2e bold'

# ============================================
# Sensible defaults (from tmux-sensible plugin)
# ============================================

# Address vim mode switching delay
set -s escape-time 0

# Increase repeat timeout
set -g repeat-time 600

# Emacs key bindings in command prompt
set -g status-keys emacs

# Allow for faster key repetition
set -s escape-time 0

# ============================================
# Plugins (TPM - Tmux Plugin Manager)
# ============================================

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'

# Plugin settings
set -g @resurrect-strategy-nvim 'session'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Initialize TPM (keep this line at the very bottom)
run '~/.tmux/plugins/tpm/tpm'

TMUX_CONF_EOF

    success "Created tmux.conf with TPM and plugins"
}

# Install tmux plugins using TPM
install_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ ! -d "$tpm_dir" ]]; then
        error "TPM not found. Cannot install plugins."
        return 1
    fi

    info "Installing tmux plugins..."

    # Install plugins using TPM's install script
    bash "$tpm_dir/bin/install_plugins" >>"$LOG_FILE" 2>&1 && \
        success "Installed tmux plugins" || \
        warn "Some plugins may have failed to install (check logs)"
}

# Main installation function
install_tmux() {
    print_section "📺 Configuring Tmux"

    # Note: tmux is already installed by cli-tools-core or cli-tools-enhanced module
    if ! command -v tmux &>/dev/null; then
        error "tmux not found. Install cli-tools-core or cli-tools-enhanced module first."
        return 1
    fi

    # Install TPM (Tmux Plugin Manager)
    install_tpm

    # Create tmux config with plugins
    create_tmux_config

    # Install plugins
    install_tmux_plugins

    echo ""
    info "Tmux Configuration Complete"
    echo ""
    echo "Key features:"
    echo "  • Prefix key: Ctrl-Space (instead of Ctrl-b)"
    echo "  • Split panes: prefix + | (vertical) or - (horizontal)"
    echo "  • Navigate panes: prefix + h/j/k/l"
    echo "  • Resize panes: prefix + H/J/K/L"
    echo "  • Switch windows: Shift + Left/Right arrow"
    echo "  • Reload config: prefix + r"
    echo ""
    echo "Plugins installed:"
    echo "  • tmux-sensible - Sensible defaults"
    echo "  • tmux-resurrect - Save/restore sessions"
    echo "  • tmux-continuum - Auto-save sessions (every 15 min)"
    echo "  • tmux-yank - Better copy/paste"
    echo "  • vim-tmux-navigator - Seamless vim/tmux navigation"
    echo ""

    success "Tmux configured with TPM and plugins"
}

# Export the main function
export -f install_tmux
