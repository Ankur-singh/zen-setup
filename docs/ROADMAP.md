# Zen Roadmap

> Ideas and improvements to enhance the developer experience.

## Status Legend

| Status | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Completed |
| `[?]` | Needs discussion |

---

## Installation & Onboarding

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Interactive Installer (TUI)** | Add TUI using `gum` or `charmbracelet/huh` for component selection, git config, and profile choice. Usage: `curl ... \| bash -s -- --interactive` | Medium | High |
| `[ ]` | **Dry-run Mode** | Add `--dry-run` flag to show what would be installed without making changes | Low | Medium |
| `[ ]` | **Pre-flight Check** | Add `make preflight` or `zen doctor` to check disk space, network, conflicts, and shell compatibility | Low | High |

---

## Configuration & Customization

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Profile Presets** | Create curated presets in `vars/profiles/`: `minimal.yml`, `standard.yml`, `full.yml`, `ml.yml`, `devops.yml`, `frontend.yml`. Usage: `./bootstrap.sh --profile ml` | Medium | High |
| `[ ]` | **Local Config Generator** | Add `make init-local` that creates `vars/local.yml` interactively with prompts for git name, email, and component choices | Low | Medium |
| `[ ]` | **Node.js/JavaScript Role** | Add `roles/nodejs/` with fnm or mise for version management, pnpm, and common global tools (typescript, eslint, prettier) | Medium | High |

---

## Debugging & Troubleshooting

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Verbose Logging** | Add `--verbose` or `-v` flag that outputs detailed logs to `~/.zen-install.log` | Low | Medium |
| `[ ]` | **Health Check Command** | Add `zhealth` command that verifies all tools are installed, shows versions, flags outdated tools, and suggests fixes | Low | High |
| `[ ]` | **Rollback Command** | Add `zrollback` to restore configs from backups. Support `--latest` flag and interactive mode | Medium | Medium |

---

## Missing Tools & Features

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Kubernetes Role** | Create `roles/kubernetes/` with kubectl, k9s, helm, kubectx/kubens | Medium | Medium |
| `[ ]` | **Cloud CLI Role** | Create `roles/cloud/` with aws-cli, gcloud, azure-cli. Configurable via `cloud_providers: [aws, gcp]` | Medium | Medium |
| `[ ]` | **Mise Version Manager** | Add mise as unified polyglot version manager (Python, Node, Ruby, Go, Rust, Java). Could simplify Python role | Medium | Medium |
| `[ ]` | **SSH Key Management** | Add optional SSH key generation and GitHub upload via `gh`. Variables: `setup_ssh_key`, `ssh_key_type`, `upload_to_github` | Low | Medium |
| `[ ]` | **GPG Commit Signing** | Add optional GPG key setup for signed commits | Low | Low |

---

## Developer Workflow

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Project Templates (`zinit`)** | Add `zinit` command to scaffold projects: `zinit python`, `zinit typescript`, `zinit docker` | Medium | Medium |
| `[ ]` | **Dotfiles Sync** | Add `zsync` command to backup/restore configs to a personal git repo | Medium | Medium |
| `[ ]` | **Zsh Plugin Manager** | Add optional zsh plugin manager support (zinit/antidote) with zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions | Medium | Medium |

---

## Documentation & Discoverability

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Cheatsheet PDF** | Generate printable cheatsheet of key commands for pinning or wallpaper | Low | Low |
| `[ ]` | **Improved `zhelp`** | Make `zhelp` searchable and categorized: `zhelp git`, `zhelp --search "docker"` | Low | Medium |
| `[ ]` | **Onboarding Tour** | Add `ztour` command that walks new users through features interactively with demos | Medium | Medium |

---

## Testing & Quality

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **GitHub Actions CI** | Add workflow to test installation on Ubuntu and macOS runners, run ansible-lint, validate YAML | Medium | High |
| `[ ]` | **Molecule Tests** | Add Molecule tests for each role to verify they work in isolation | High | Medium |
| `[ ]` | **Version Pinning Automation** | Create script to auto-update `tool_versions` in `common.yml` from GitHub releases: `make update-versions` | Low | Medium |

---

## Outside-the-Box Ideas

| Status | Idea | Description | Effort | Impact |
|--------|------|-------------|--------|--------|
| `[ ]` | **Web Configurator** | Create web page for users to select components, fill in config, and generate custom install command | High | High |
| `[ ]` | **Zen Themes** | Add theme support (catppuccin, dracula, nord, gruvbox, tokyo-night) applied across tmux, bat, fzf, lazygit, starship | Medium | Medium |
| `[ ]` | **Team/Org Configs** | Support company-specific overlays: `./bootstrap.sh --org mycompany` fetches from private repo | Medium | Medium |
| `[ ]` | **AI Assistant Integration** | Deeper AI integration: `zask` for codebase questions, `zexplain` for command explanations | High | Medium |
| `[ ]` | **Analytics Dashboard** | Opt-in anonymous usage stats to track popular roles and common failures | High | Low |

---

## Priority Matrix

### Quick Wins (Low Effort, High Impact)

- [ ] `zhealth` command
- [ ] `--dry-run` flag
- [ ] Pre-flight check
- [ ] Improved `zhelp`

### High Value (Medium Effort, High Impact)

- [ ] GitHub Actions CI
- [ ] Profile presets
- [ ] Interactive installer
- [ ] Node.js role

### Nice to Have

- [ ] Kubernetes role
- [ ] Cloud CLI role
- [ ] Project templates
- [ ] Zen themes

---

## Notes

_Add implementation notes, decisions, and discussions here._

---

Last updated: 2025-01-09
