# Development Environment Dotfiles

A **chezmoi-based** dotfiles repository that creates a powerful, streamlined development environment.

## Quick Setup

```bash
# Install chezmoi and apply dotfiles
chezmoi init --apply https://github.com/jamespetran/dotfile-macOS.git

# Restart shell
exec zsh
```

That's it! Your development environment is ready.

## Installed Tools

- `ripgrep` (`rg`) - fast grep replacement
- `fd` - fast find replacement  
- `fzf` - fuzzy finder
- `bat` - cat with syntax highlighting
- `broot` - interactive file navigator
- `jq` - JSON processor
- `yq` - YAML processor
- `lazygit` - git TUI
- `git-delta` - better git diffs
- `gh` - GitHub CLI
- `zellij` - terminal multiplexer
- `atuin` - shell history
- `zoxide` - smart cd
- `btop` - system monitor
- `hyperfine` - benchmarking
- `tokei` - code statistics
- `just` - task runner
- `mise` - runtime manager (Python, Node.js)
- `terraform` - infrastructure as code
- `tflint` - terraform linter
- `terraform-docs` - terraform documentation
- `terragrunt` - terraform wrapper
- `infracost` - infrastructure cost estimation
- `tenv` - terraform version manager