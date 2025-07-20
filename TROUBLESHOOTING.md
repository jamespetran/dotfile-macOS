# Troubleshooting Guide

This guide helps resolve common issues with the cross-platform dotfiles setup.

## Quick Diagnostics

Run these commands to diagnose issues:

```bash
# Full system validation
./test-crossplatform.sh

# Check specific components
./test-integration.sh    # Development tools
./test-performance.sh    # Performance issues

# In your shell
check_dependencies      # Missing dependencies
sysinfo                 # System information
platform_tips           # Platform-specific tips
```

## Common Issues

### Cross-Platform Issues

#### Wrong Homebrew Path
**Symptom**: `brew: command not found` or brew installed in wrong location

**Solution**:
```bash
# Check expected location
./test-crossplatform.sh | grep "Homebrew"

# Fix PATH in .zshrc
chezmoi edit dot_zshrc
# Ensure it uses {{ .paths.homebrew.bin }}
```

#### GNU Tools Missing on macOS
**Symptom**: Scripts fail with `xargs: invalid option -- r`

**Solution**:
```bash
# Install GNU tools
brew install coreutils findutils gnu-sed grep

# Verify installation
gls --version
gsed --version
```

#### Container Runtime Not Working
**Symptom**: Docker/Podman commands fail

**macOS Solution**:
```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop
open -a Docker
```

**Linux Solution**:
```bash
# Install Podman
sudo dnf install podman  # Fedora
sudo apt install podman  # Ubuntu/Debian

# Start Podman
systemctl --user start podman
```

### Shell Issues

#### Slow Shell Startup
**Symptom**: Shell takes >1 second to start

**Diagnosis**:
```bash
# Measure startup time
./test-performance.sh

# Profile zsh startup
zsh -xvs
```

**Solutions**:
- Remove unused Oh My Zsh plugins
- Check for slow custom scripts
- Clear completion cache: `rm -f ~/.zcompdump*`

#### Prompt Rendering Issues
**Symptom**: Broken characters in prompt

**Solution**:
```bash
# Reconfigure Powerlevel10k
p10k configure

# Install recommended fonts
# macOS: Download from https://github.com/romkatv/powerlevel10k#fonts
# Linux: sudo apt/dnf install powerline-fonts
```

### Package Management

#### Homebrew Installation Fails
**Symptom**: Can't install Homebrew

**macOS Solution**:
```bash
# Install Xcode Command Line Tools first
xcode-select --install

# Then install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Linux Solution**:
```bash
# Install dependencies first
sudo apt install build-essential curl git  # Ubuntu/Debian
sudo dnf groupinstall 'Development Tools'  # Fedora

# Then install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Package Installation Errors
**Symptom**: `run_always_update-packages.sh.tmpl` fails

**Solution**:
```bash
# Check package manager
which brew
which apt || which dnf

# Update package definitions
chezmoi cd
cat .chezmoidata/packages.yaml

# Run with debug
bash -x run_always_update-packages.sh.tmpl
```

### Development Tools

#### Rust Not Found
**Symptom**: `cargo: command not found`

**Solution**:
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Source cargo env
source "$HOME/.cargo/env"

# Install development tools
cargo_install_essential
```

#### Python/Node.js Issues
**Symptom**: Wrong versions or not found

**Solution**:
```bash
# Check mise status
mise list

# Install/update runtimes
mise use python@3.11
mise use node@lts

# Verify
python --version
node --version
```

### Bitwarden Integration

#### Bitwarden Prompts During Shell Startup
**Symptom**: Password prompts when opening new shell

**Solution**:
```bash
# Check Bitwarden status
bw status

# Ensure vault is unlocked
bw unlock

# Check for template issues
grep -r "bitwarden" ~/.local/share/chezmoi/
```

#### GPG Signing Fails
**Symptom**: Git commits fail with GPG error

**Solution**:
```bash
# Check GPG key
gpg --list-secret-keys

# Re-import from Bitwarden
chezmoi apply --force run_onchange_import-gpg-key.sh.tmpl

# Test signing
echo "test" | gpg --clearsign
```

## Platform-Specific Issues

### macOS

#### "Operation not permitted" Errors
**Symptom**: Permission denied even with sudo

**Solution**:
- Go to System Preferences → Security & Privacy → Privacy
- Grant Terminal/iTerm Full Disk Access

#### Homebrew Slow
**Symptom**: brew commands take forever

**Solution**:
```bash
# Disable auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Clean cache
brew cleanup
```

### Linux

#### Podman Permission Issues
**Symptom**: Can't run containers without sudo

**Solution**:
```bash
# Enable rootless containers
sudo usermod -aG podman $USER

# Configure subuid/subgid
sudo usermod --add-subuids 100000-165535 $USER
sudo usermod --add-subgids 100000-165535 $USER

# Logout and login again
```

#### Homebrew Not in PATH
**Symptom**: Installed but commands not found

**Solution**:
```bash
# Add to PATH manually
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

## Getting More Help

1. **Run diagnostics**: `./test-crossplatform.sh -v` for verbose output
2. **Check logs**: `chezmoi doctor`
3. **Debug mode**: `CHEZMOI_DEBUG=1 chezmoi apply`
4. **Community help**: File an issue with output from diagnostics

## Emergency Recovery

If everything is broken:

```bash
# Backup current state
mv ~/.zshrc ~/.zshrc.backup
mv ~/.oh-my-zsh ~/.oh-my-zsh.backup

# Re-run chezmoi
chezmoi init --apply yourusername/dotfiles

# Restore if needed
mv ~/.zshrc.backup ~/.zshrc
mv ~/.oh-my-zsh.backup ~/.oh-my-zsh
```