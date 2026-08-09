# My Dotfiles

A streamlined, GNU Stow-based dotfiles repository for instantly setting up my terminal environment across Linux (CachyOS/Ubuntu) and macOS.

Currently manages configurations for:
* **Neovim** (Configured via Lua with Lazy.nvim)
* **Tmux** (Auto-installs Tmux Plugin Manager)
* **Git & SSH** (Automated Ed25519 key generation and global config)

## One-Command Bootstrap

When setting up a brand-new machine, you can run these commands directly from the web to authenticate and configure everything in minutes.

> **Note:** Ensure `curl` and `git` are installed on the base system before starting.

### Step 1: Set up Git and SSH
This script will prompt you for your name and email, configure Git, generate a secure Ed25519 SSH key, and automatically copy the public key to your clipboard so you can add it to GitHub.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AlexanderBierton/dotfiles/refs/heads/trunk/setup-git.sh)"
```

*(Stop here and add the generated SSH key to your GitHub account settings before proceeding to Step 2).*

### Step 2: Install Dependencies and Link Configs
This script will detect your OS, install GNU Stow, securely clone this repository using SSH, link the `nvim` and `tmux` configurations into your `~/.config/` directory, and install the Tmux Plugin Manager (TPM).

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AlexanderBierton/dotfiles/refs/heads/trunk/setup.sh)"
```

## Post-Installation

Once the setup script finishes, there is one manual step left:

1. Open your terminal and start Tmux by typing `tmux`.
2. Press `Prefix + I` (usually `Ctrl+b` then `Shift+i`) to tell the Tmux Plugin Manager to download and install all plugins.

## Structure and Management

This repository uses **GNU Stow** to manage symlinks. The folders at the root (like `nvim/` and `tmux/`) represent the "packages." 

Inside each package, the directory structure perfectly mirrors the home directory. When Stow runs, it creates symlinks in the home directory pointing directly back to this cloned repository.

To safely test committing to this repository, it is protected by **Gitleaks**.
1. Install pre-commit: `brew install pre-commit` (macOS) or `sudo pacman -S pre-commit` (Arch)
2. Activate the hook: `pre-commit install`
