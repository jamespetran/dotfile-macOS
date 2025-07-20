# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository for macOS development environments. Uses Bitwarden for secure credential management and provides a comprehensive set of development tools.


## Key Commands

### Chezmoi Management
- `cz apply` - Apply dotfiles changes (uses Bitwarden-aware wrapper)
- `cz diff` - Show differences between source and target files
- `cz edit <file>` - Edit a dotfile in the source directory
- `cz status` - Show status of managed files
- `cz data` - Show template data available to chezmoi

The `cz` command is a wrapper function that automatically unlocks Bitwarden when needed.

### Package Installation
- `./run_always_update-packages.sh.tmpl` - Install and upgrade packages
- `./run_weekly_safe-upgrades.sh.tmpl` - Safe weekly upgrades for CLI tools
- `./run_onchange_setup-mise.sh` - Runtime manager setup with Python/Node/Rust

### GPG Key Management
- `./run_onchange_import-gpg-key.sh.tmpl` - Import GPG key from Bitwarden (when needed)
- `./run_onchange_setup-gitconfig.sh.tmpl` - Configure git with Bitwarden email
- Key ID: `21D39CC1D0B3B44A`
- **Optimized**: Only calls Bitwarden if key/config actually needs updating

## Architecture

### File Structure
- `dot_*` files become dotfiles in the home directory (e.g., `dot_zshrc` → `~/.zshrc`)
- `*.tmpl` files are processed as Go templates with access to Bitwarden data
- `.chezmoidata/packages.yaml` - Package lists for Homebrew and Cargo
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

**macOS-focused installation with 4 layers:**
1. **Homebrew** - Modern CLI tools and development utilities
2. **Language toolchains** - Rust (cargo), Node.js (mise), Python (mise)
3. **Shell framework** - Oh My Zsh with plugins and Powerlevel10k theme
4. **Configuration** - Tool-specific configs and optimizations

**Script Types:**
- `run_onchange_*` - Execute when script content changes
- `run_always_*` - Execute on every `chezmoi apply`
- Templates processed with **runtime** Bitwarden access (not template-time)

### Development Tools Included

- Modern CLI alternatives: `bat`, `fd`, `ripgrep`, `zoxide`
- Git tools: `git-delta`, `lazygit`, `gh` (GitHub CLI)  
- Terminal multiplexer: `zellij`
- Container tools: `docker`, `colima`
- File navigation: `broot`, `fzf`
- Data processing: `jq`, `yq`
- Monitoring: `btop`
- Language runtimes: Python, Node.js (mise), Rust toolchain
- Rust tools: `cargo-nextest`, `cargo-llvm-cov`
- Python tools: `uv`
- Infrastructure: `terraform`, `tflint`, `terraform-docs`, `infracost`, `tenv`, `checkov`, `trivy`
- Performance tools: `hyperfine`, `tokei`


## Recent Critical Fix: Bitwarden Shell Startup Optimization

**Problem Solved**: Template-time Bitwarden calls caused console output during shell initialization, triggering Powerlevel10k instant prompt warnings.

**Files Modified**:
- `run_onchange_setup-gitconfig.sh.tmpl` - Now uses `bw get item` at runtime
- `run_onchange_import-gpg-key.sh.tmpl` - Now uses `bw get notes` at runtime

**Result**: Clean shell startup, no unnecessary Bitwarden prompts.

## Docker Auto-Management: A Case Study in AI Development

### The Problem
Initially, this repository included a broken LaunchAgent for Colima auto-start that used an invalid `--very-quiet` flag. This caused Docker to be unavailable after Mac restarts, requiring manual intervention.

### The AI Coaching Process
This section documents how Claude Code was coached to move beyond surface-level assistance to deliver robust solutions:

**Initial Failure Pattern:**
- Claude acted like a "naive intern" - asking permission for every action
- Provided surface-level fixes without understanding root causes
- Treated system configuration casually, leading to broken functionality
- Failed to take responsibility for creating production issues

**Coaching Breakthroughs:**
1. **Accountability**: Forced Claude to trace its own git history to understand exactly what it had broken and when
2. **Systems Thinking**: Required understanding that dotfiles are real infrastructure, not toy configurations
3. **Delegation vs Control**: Taught Claude to work WITH subagents rather than micromanaging them
4. **Problem Ownership**: Instead of "Here's what you could do," demanded "Here's what I will do"

### The Solution: Smart Docker Management

**Implementation**: `dot_oh-my-zsh/custom/docker-smart.zsh`

**Key Features:**
- **Lazy initialization**: Colima starts only when Docker commands are used
- **Auto-cleanup**: Stops Colima after configurable idle timeout (default: 10 minutes)
- **Container-aware**: Won't stop if containers are running
- **Resource management**: Tracks activity, manages background cleanup processes
- **Zero overhead**: No system resources used when Docker isn't needed

**Rust-like Borrow System Philosophy:**
- Resources are "borrowed" only when needed
- Automatic cleanup when no longer in use
- Safety checks prevent premature resource release
- Zero-cost abstractions - no overhead when unused

**Usage:**
```bash
# Just use Docker normally - Colima starts automatically
docker run -it --rm alpine sh

# Management commands available
docker-smart-status    # Check system state
docker-smart-stop      # Force cleanup
docker-smart-reset     # Reset state files
```

**Configuration:**
```bash
export DOCKER_SMART_ENABLED=true          # Enable smart management
export DOCKER_IDLE_TIMEOUT=600            # Idle timeout (seconds)
export DOCKER_CLEANUP_AGGRESSIVE=false    # Aggressive cleanup on stop
export DOCKER_SMART_LOG_LEVEL=1           # Logging (0=silent, 1=info, 2=debug)
```

### Lessons for Future Claude Instances

1. **Take Ownership**: If you break something, fix it completely - don't just patch symptoms
2. **Use Git as Memory**: The repository history contains your previous decisions and mistakes
3. **Validate System Integration**: Before writing system configs, verify CLI interfaces actually exist
4. **Embrace Delegation**: Let subagents solve complete problems instead of micromanaging fragments
5. **Think in Systems**: Understand that configuration changes affect real workflows and productivity

The resulting Docker management system provides the "just works" experience while following the repository's philosophy of reliability, performance, and minimal system complexity.

## Important Notes

- The repository uses GPG signing for commits (automatically configured)
- Bitwarden only prompts when configuration changes are actually needed
- All installation scripts are idempotent and safe to run multiple times
- Zsh is the target shell with Oh My Zsh framework
- Setup works on macOS with Homebrew package management
- All scripts include proper error handling and exit status reporting
- Docker commands "just work" via intelligent Colima management

## Documentation

- **README.md** - Quick setup guide and installed tools overview
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

### Validate Installation

```bash
# Essential tools
which git curl zsh docker || echo "Essential tools missing"
which rg bat fzf fd || echo "CLI tools missing" 
which lazygit gh zellij atuin broot || echo "Dev tools missing"

# Homebrew
which brew && brew list | head -5 || echo "Homebrew incomplete"

# Language toolchains  
which cargo node && mise list || echo "Language tools incomplete"

# Shell framework
echo $ZSH && ls $ZSH/custom/plugins || echo "Shell framework incomplete"

# Container runtime
docker --version && echo "✅ Container runtime available"
```

### Upgrade Management

```bash
# Daily (automatic on cz apply)
./run_always_update-packages.sh.tmpl       # Install and upgrade all packages

# Weekly (manual)
./run_weekly_safe-upgrades.sh.tmpl         # Safe CLI tool upgrades only

# Language runtime management
mise use python@3.11                       # Switch Python version
mise use node@lts                          # Switch Node version
```

### Debug Common Issues

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

# Container runtime
docker ps -a                                # Check containers
docker system info                          # System status

# Language runtimes
mise list                                   # Runtime versions
```

### Common Troubleshooting

1. **Package failures**: Check internet connection and Homebrew status with `brew doctor`
2. **Git signing fails**: Verify GPG key import with `gpg --list-secret-keys`
3. **Runtime conflicts**: Use `mise use` to switch versions
4. **Container not starting**: Check docker/colima daemon status and permissions
5. **Shell startup prompts**: Verify `bw status` and vault items
6. **Template errors**: Usually Bitwarden access or missing vault items
7. **Performance issues**: Verify installation layers completed successfully