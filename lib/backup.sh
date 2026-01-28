#!/bin/bash
# lib/backup.sh - Backup functionality for dotfiles and configurations
#
# Provides functions to backup existing configurations before modification

# Source utilities for pretty output
# Note: Don't redefine SCRIPT_DIR here to avoid conflicts
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_DIR/utils.sh"

# Generate timestamp for backup files
get_backup_timestamp() {
    date +%Y%m%d_%H%M%S
}

# Backup a single file if it exists
# Usage: backup_file /path/to/file
backup_file() {
    local file="$1"
    local timestamp=$(get_backup_timestamp)

    if [[ -f "$file" ]]; then
        local backup="${file}.backup.${timestamp}"
        cp "$file" "$backup"
        info "Backed up: $file → $backup"
        return 0
    fi

    return 1
}

# Backup dotfiles based on components being installed
# Usage: backup_dotfiles_for_components component1 component2 ...
backup_dotfiles_for_components() {
    local components=("$@")
    local timestamp=$(get_backup_timestamp)
    local backed_up=()
    local files_to_backup=()

    # Determine which files need backup based on components
    for component in "${components[@]}"; do
        case "$component" in
            shell)
                files_to_backup+=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.zprofile" "$HOME/.inputrc")
                ;;
            tmux)
                files_to_backup+=("$HOME/.tmux.conf")
                ;;
            git)
                files_to_backup+=("$HOME/.gitconfig")
                ;;
        esac
    done

    # Remove duplicates
    local unique_files=($(printf "%s\n" "${files_to_backup[@]}" | sort -u))

    # Only show backup section if there are files to backup
    if [[ ${#unique_files[@]} -eq 0 ]]; then
        return 0
    fi

    print_section "Backing Up Existing Configurations"

    # Backup each file
    for file in "${unique_files[@]}"; do
        if [[ -f "$file" ]]; then
            local backup="${file}.backup.${timestamp}"
            if cp "$file" "$backup" 2>/dev/null; then
                backed_up+=("$(basename "$file")")
            fi
        fi
    done

    if [[ ${#backed_up[@]} -gt 0 ]]; then
        success "Backed up ${#backed_up[@]} files: ${backed_up[*]}"
    else
        skip "No existing configuration files to backup"
    fi
}

# Backup multiple dotfiles (legacy function - backs up all)
# Usage: backup_dotfiles
backup_dotfiles() {
    local timestamp=$(get_backup_timestamp)
    local backed_up=()

    print_section "Backing Up Existing Configurations"

    # List of files to backup
    local files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.bash_profile"
        "$HOME/.zprofile"
        "$HOME/.tmux.conf"
        "$HOME/.inputrc"
        "$HOME/.gitconfig"
    )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local backup="${file}.backup.${timestamp}"
            if cp "$file" "$backup" 2>/dev/null; then
                backed_up+=("$(basename "$file")")
            fi
        fi
    done

    if [[ ${#backed_up[@]} -gt 0 ]]; then
        success "Backed up ${#backed_up[@]} files: ${backed_up[*]}"
    else
        skip "No existing configuration files to backup"
    fi
}

# Restore a specific backup
# Usage: restore_backup /path/to/file.backup.20240127_123456
restore_backup() {
    local backup_file="$1"

    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
        return 1
    fi

    # Extract original filename (remove .backup.TIMESTAMP)
    local original_file="${backup_file%.backup.*}"

    if cp "$backup_file" "$original_file" 2>/dev/null; then
        success "Restored: $backup_file → $original_file"
        return 0
    else
        error "Failed to restore: $backup_file"
        return 1
    fi
}

# List available backups for a file
# Usage: list_backups ~/.bashrc
list_backups() {
    local file="$1"
    local backups=("${file}".backup.*)

    if [[ -f "${backups[0]}" ]]; then
        echo "Available backups for $(basename "$file"):"
        for backup in "${backups[@]}"; do
            if [[ -f "$backup" ]]; then
                local timestamp=$(basename "$backup" | sed 's/.*backup\.//')
                local size=$(du -h "$backup" | cut -f1)
                echo "  - $timestamp ($size)"
            fi
        done
    else
        echo "No backups found for $(basename "$file")"
    fi
}

# Clean old backups (keep only last N backups)
# Usage: cleanup_old_backups /path/to/file 5
cleanup_old_backups() {
    local file="$1"
    local keep="${2:-5}"  # Default: keep last 5 backups

    local backups=("${file}".backup.*)
    local count=${#backups[@]}

    if [[ $count -gt $keep ]]; then
        local to_remove=$((count - keep))
        info "Cleaning up old backups (keeping last $keep)"

        # Sort backups by timestamp and remove oldest ones
        local sorted=($(printf '%s\n' "${backups[@]}" | sort))
        for ((i=0; i<to_remove; i++)); do
            if [[ -f "${sorted[$i]}" ]]; then
                rm "${sorted[$i]}"
                skip "Removed old backup: $(basename "${sorted[$i]}")"
            fi
        done
    fi
}

# Create a full backup directory with all configs
# Usage: create_backup_snapshot /path/to/backup/dir
create_backup_snapshot() {
    local backup_dir="$1"
    local timestamp=$(get_backup_timestamp)
    local snapshot_dir="${backup_dir}/zen-backup-${timestamp}"

    mkdir -p "$snapshot_dir"

    # Files to include in snapshot
    local files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.bash_profile"
        "$HOME/.zprofile"
        "$HOME/.tmux.conf"
        "$HOME/.inputrc"
        "$HOME/.gitconfig"
        "$HOME/.config/lazygit/config.yml"
        "$HOME/.config/btop/btop.conf"
    )

    info "Creating backup snapshot: $snapshot_dir"

    local copied=0
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            # Preserve directory structure
            local rel_path="${file#$HOME/}"
            local dest_dir="$(dirname "$snapshot_dir/$rel_path")"
            mkdir -p "$dest_dir"
            cp "$file" "$snapshot_dir/$rel_path" 2>/dev/null && ((copied++))
        fi
    done

    if [[ $copied -gt 0 ]]; then
        success "Created snapshot with $copied files: $snapshot_dir"
        return 0
    else
        error "No files to backup"
        rmdir "$snapshot_dir" 2>/dev/null
        return 1
    fi
}

# Export functions for use in other scripts
export -f get_backup_timestamp
export -f backup_file
export -f backup_dotfiles
export -f backup_dotfiles_for_components
export -f restore_backup
export -f list_backups
export -f cleanup_old_backups
export -f create_backup_snapshot
