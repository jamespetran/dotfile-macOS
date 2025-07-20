# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository with **two installation modes**: minimal (recommended) and full. Uses Bitwarden for secure credential management and supports both traditional host-based development and modern dev container workflows.

## Installation Modes

### Minimal Mode (Default/Recommended)
- **Purpose**: Clean base system + dev containers for IntelliJ IDEA Ultimate
- **Host installs**: Shell environment, essential CLI tools, container runtime only
- **Language development**: Happens in dev containers (Python, Node, Rust)
- **Package file**: `packages-minimal.yaml`
- **Best for**: Clean system, no version conflicts, container-based development

### Full Mode (Legacy/Power Users)  
- **Purpose**: Everything on host system for maximum performance
- **Host installs**: All language runtimes, build tools, performance tools
- **Language development**: Directly on host with mise runtime management
- **Package file**: `packages.yaml` (original)
- **Best for**: Bare metal development, maximum tool availability

## Key Commands

### Chezmoi Management
- `cz apply` - Apply dotfiles changes (uses Bitwarden-aware wrapper)
- `cz diff` - Show differences between source and target files
- `cz edit <file>` - Edit a dotfile in the source directory
- `cz status` - Show status of managed files
- `cz data` - Show template data available to chezmoi

The `cz` command is a wrapper function that automatically unlocks Bitwarden when needed.

### Mode Management
- `./switch-to-minimal.sh` - Switch from full to minimal mode (with backup)
- Switch to full: Requires fresh chezmoi installation

### Package Installation

#### Minimal Mode
- `./run_always_update-packages.sh.tmpl` - Ensure minimal packages installed (no upgrades)
- `./run_weekly_safe-upgrades.sh.tmpl` - Safe weekly upgrades for CLI tools
- `./run_onchange_setup-mise-minimal.sh.tmpl` - Minimal mise setup (shell tools only)

#### Full Mode  
- `./run_onchange_install-dev-environment.sh.tmpl` - Full environment bootstrap (one-time)
- `./run_always_update-packages.sh.tmpl` - Install and upgrade all packages (every apply)
- `./run_onchange_setup-mise.sh.tmpl` - Full mise setup with Python/Node/Rust

### GPG Key Management
- `./run_onchange_import-gpg-key.sh.tmpl` - Import GPG key from Bitwarden (when needed)
- `./run_onchange_setup-gitconfig.sh.tmpl` - Configure git with Bitwarden email
- Key ID: `21D39CC1D0B3B44A`
- **Optimized**: Only calls Bitwarden if key/config actually needs updating

## Architecture

### File Structure
- `dot_*` files become dotfiles in the home directory (e.g., `dot_zshrc` → `~/.zshrc`)
- `*.tmpl` files are processed as Go templates with access to Bitwarden data
- `.chezmoidata/packages.yaml` - Full mode package lists
- `.chezmoidata/packages-minimal.yaml` - Minimal mode package lists  
- `devcontainer-templates/` - Pre-configured dev containers for Python, Rust, Node.js
- Shell customizations are in `dot_oh-my-zsh/custom/`

### Bitwarden Integration (Recently Optimized)
**IMPORTANT CHANGE**: Fixed shell startup prompt issues by moving Bitwarden calls from template-time to runtime.

**Old Approach** (caused shell startup prompts):
- Used `{{ bitwarden }}` template functions
- Evaluated during every chezmoi operation
- Caused console output during shell initialization

**New Approach** (optimized):
- Uses `bw get` CLI commands at script runtime only
- Scripts check if changes are needed before calling Bitwarden
- No shell startup interruptions or Powerlevel10k warnings

**Required Bitwarden Items:**
- GPG private key stored as secure note "GPG Private Key"
- GitHub email in "github.com" item's "noreply_email" field
- Bitwarden CLI (`bw`) installed and unlocked when changes needed

### Installation Architecture

# THIS IS OUT OF DATE. THERE IS ONLY ONE MODE. THIS IS ONLY MAC OS. NO LINUX. NO PODMAN.

README.MD IS MORE UP TO DATE

#### Minimal Mode (4 layers)
1. **OS packages** - Essential system utilities (git, curl, zsh, docker)
2. **Homebrew** - Modern CLI tools (ripgrep, bat, fzf, etc.)
3. **Shell framework** - Oh My Zsh with plugins and Powerlevel10k theme
4. **Configuration** - Tool-specific configs and aliases

#### Full Mode (6 layers) 
1. **OS packages** - dnf (Fedora) or apt (Debian/Ubuntu) - Essential system libraries
2. **Homebrew** - Modern CLI alternatives and cross-platform tools
3. **Language toolchains** - Rust (rustup), Node.js (mise), Python (mise)
4. **Shell framework** - Oh My Zsh with plugins and Powerlevel10k theme
5. **Development tools** - GitHub CLI, Zellij, lazygit, performance tools  
6. **Configuration** - Tool-specific configs and optimizations

#### Dev Containers (Minimal Mode)
- **Language runtimes** live in containers instead of host
- **Project isolation** via container-per-project
- **IntelliJ integration** via dev container support
- **Shared caches** for performance (cargo registry, npm cache, etc.)

**Script Types:**
- `run_onchange_*` - Execute when script content changes
- `run_always_*` - Execute on every `chezmoi apply`
- Templates processed with **runtime** Bitwarden access (not template-time)

### Development Tools Included

#### Both Modes
- Modern CLI alternatives: `bat`, `fd`, `ripgrep`, `zoxide`
- Git tools: `git-delta`, `lazygit`, `gh` (GitHub CLI)  
- Terminal multiplexer: `zellij`
- Container tools: `docker`
- File navigation: `broot`, `fzf`
- Data processing: `jq`, `yq`
- Monitoring: `btop`, `htop`

#### Full Mode Only
- Language runtimes: Python 3.11, Node.js LTS, Rust toolchain
- Build tools: `gcc`, `cmake`
- Rust tools: `cargo-nextest`, `cargo-watch`, `cargo-edit`
- Python tools: `poetry`, `pipx`, `huggingface_hub`

## Dev Container Templates (Minimal Mode)

Located in `devcontainer-templates/` directory:

### Python Container (`python/.devcontainer.json`)
- **Base**: `mcr.microsoft.com/devcontainers/python:3.11`
- **Features**: poetry, pipx, common-utils
- **Environment**: `PIP_REQUIRE_VIRTUALENV=false` (allows global installs)
- **Mounts**: zsh config, oh-my-zsh
- **IDE**: IntelliJ backend configured

### Rust Container (`rust/.devcontainer.json`)  
- **Base**: `mcr.microsoft.com/devcontainers/rust:1`
- **Features**: common-utils
- **Tools**: cargo-nextest, cargo-watch, cargo-edit
- **Mounts**: zsh config, cargo registry cache

### Node.js Container (`node/.devcontainer.json`)
- **Base**: `mcr.microsoft.com/devcontainers/javascript-node:20`
- **Tools**: pnpm, yarn (global install)
- **Mounts**: zsh config, npm cache
- **IDE**: IntelliJ backend configured

### Usage with IntelliJ IDEA Ultimate
1. Copy appropriate `.devcontainer.json` to project root
2. **Tools → Dev Containers → Create Dev Container**
3. IntelliJ builds and connects to container
4. All language tools available inside container only

## Recent Critical Fix: Bitwarden Shell Startup Optimization

**Problem Solved**: Template-time Bitwarden calls caused console output during shell initialization, triggering Powerlevel10k instant prompt warnings.

**Files Modified**:
- `run_onchange_setup-gitconfig.sh.tmpl` - Now uses `bw get item` at runtime
- `run_onchange_import-gpg-key.sh.tmpl` - Now uses `bw get notes` at runtime

**Result**: Clean shell startup, no unnecessary Bitwarden prompts.

## Important Notes

- The repository uses GPG signing for commits (automatically configured)
- Bitwarden only prompts when configuration changes are actually needed
- All installation scripts are idempotent and safe to run multiple times
- Zsh is the target shell with Oh My Zsh framework
- Setup works in both native environments and toolbox containers
- All scripts include proper error handling and exit status reporting

## Documentation

- **USAGE.md** - Comprehensive user guide for all tools and workflows
- **CLAUDE.md** - This file, for Claude Code instances
- All configurations follow Rust principles: performance, safety, explicit error handling

## Power User Features Added

**Phase 1: Shell Intelligence**
- Atuin: Encrypted, searchable shell history
- Enhanced zsh: 50k history, smart completion, custom functions
- Zellij layouts: zdev, zrust, zai, zmon
- Advanced git: git-absorb, git-branchless with enhanced workflows

**Phase 2: Development Workflow**
- mise: Universal runtime management (Python, Node.js)
- just: Command runner with Rust and AI project templates
- direnv: Automatic environment switching with AI-optimized layouts
- GitHub CLI: Extensions and streamlined workflow

**Phase 3: System Intelligence**
- cargo-nextest: Blazing-fast Rust testing
- Dataset analysis: Smart tools for AI/ML data work (dv, dstats, dfind, dcheck)
- Notification system: Smart background task management
- Intelligent file navigation: broot with development-optimized configuration

**Design Philosophy:**
- **Performance First**: Modern Rust-based tools throughout the stack
- **Dual Interface**: Non-interactive (cat, ls) for speed, interactive (bcat, br) for exploration  
- **Smart Caching**: Shell completion caching, encrypted history
- **Secure by Default**: GPG signing, Bitwarden credentials, encrypted shell history
- **Zero-Cost Abstractions**: Only install and configure what's actively used
- **Idempotent Operations**: All scripts safe to run multiple times
- **Layered Dependencies**: Clear installation ordering for reliability

## Maintenance & Debugging for Claude

### Validate Installation (Mode-Specific)

#### Minimal Mode Validation
```bash
# Essential tools (should be present)
which git curl zsh docker || echo "Essential tools missing"
which rg bat fzf fd || echo "CLI tools missing" 
which lazygit gh zellij atuin broot || echo "Dev tools missing"

# Language tools (should NOT be on host)
which python3 node cargo && echo "⚠️ Language runtimes on host (should be in containers)"

# Container runtime
docker --version && echo "✅ Container runtime available"
```

#### Full Mode Validation  
```bash
# Layer 1: OS packages
which gcc git curl python3 || echo "Layer 1 incomplete"

# Layer 2: Homebrew
which brew && brew list | head -5 || echo "Layer 2 incomplete"

# Layer 3: Language toolchains  
which cargo node && mise list || echo "Layer 3 incomplete"

# Layer 4: Shell framework
echo $ZSH && ls $ZSH/custom/plugins || echo "Layer 4 incomplete"

# Layer 5: Development tools
which gh lazygit zellij atuin || echo "Layer 5 incomplete"

# Layer 6: Performance tools
cargo nextest --version || echo "Layer 6 incomplete"
```

### Upgrade Management

#### Minimal Mode  
```bash
# Daily (automatic on cz apply)
./run_always_update-packages.sh.tmpl       # Ensure packages installed (no upgrades)

# Weekly (manual)
./run_weekly_safe-upgrades.sh.tmpl         # Safe CLI tool upgrades only

# Check what needs manual upgrade
cat manual-upgrade-checklist.md            # Critical tools checklist
```

#### Full Mode
```bash
# Daily (automatic on cz apply)  
./run_always_update-packages.sh.tmpl       # Install and upgrade all packages

# Language runtime management
mise use python@3.11                       # Switch Python version
mise use node@lts                          # Switch Node version
```

### Debug Common Issues

#### Both Modes
```bash
# Bitwarden integration
bw status                                    # Check vault status
bw get item "github.com" | jq '.fields[]'    # Verify required fields

# Git configuration
git config --global -l | grep -E "user\.|signing"
gpg --list-secret-keys 21D39CC1D0B3B44A

# Shell performance
atuin stats                                 # Shell history stats
zsh -c 'time zsh -i -c exit'               # Shell startup time
```

#### Minimal Mode Specific
```bash
# Container runtime
docker ps -a                                # Check containers
docker system info                          # System status

# Dev container issues
cat devcontainer-templates/README.md        # Usage instructions
```

#### Full Mode Specific
```bash
# Build performance  
mise list                                   # Runtime versions

# Python environment
pipx list                                   # Global Python tools
poetry --version                           # Poetry status
```

### Common Troubleshooting

#### Minimal Mode
1. **Missing language tools**: Install in dev container, not on host
2. **Container not starting**: Check docker daemon status and permissions
3. **IntelliJ can't find tools**: Use dev container integration
4. **Shell startup prompts**: Verify `bw status` and vault items

#### Full Mode  
1. **pip requires virtualenv**: Check mise environment variables in config
3. **Runtime conflicts**: Use `mise use` to switch versions
4. **Template errors**: Usually Bitwarden access or missing vault items

#### Both Modes
1. **Package failures**: Check internet connection, sudo access, package manager status
2. **Git signing fails**: Verify GPG key import with `gpg --list-secret-keys`
3. **Performance issues**: Verify installation layers completed successfully