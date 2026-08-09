#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# --- Configuration ---
# Updated to use the SSH URL instead of HTTPS
DOTFILES_REPO="git@github.com:AlexanderBierton/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Starting dotfiles setup..."

# 1. Install GNU Stow based on the OS package manager
if ! command -v stow &> /dev/null; then
    echo "📦 GNU Stow not found. Installing..."
    if command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm stow
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v brew &> /dev/null; then
        brew install stow
    else
        echo "❌ No supported package manager found (apt, pacman, or brew)."
        exit 1
    fi
else
    echo "✅ GNU Stow is already installed."
fi

# 2. Clone or update the dotfiles repository
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "📂 Dotfiles repository already exists at $DOTFILES_DIR."
    echo "⬇️ Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull origin trunk
else
    echo "📥 Cloning dotfiles repository via SSH..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# 3. Prevent the "Stow .config Trap"
echo "📁 Ensuring ~/.config exists..."
mkdir -p "$HOME/.config"

# 4. Link the packages
echo "🔗 Stowing Neovim and Tmux..."
stow -v -R -t "$HOME" nvim tmux

# 5. Install Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "📦 Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "✅ TPM is already installed."
fi

echo "🎉 Setup complete! Your configs are linked."
echo "💡 Note: Open tmux and press 'Prefix + I' to install your plugins."
