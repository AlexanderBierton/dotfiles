#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# --- Configuration ---
# Updated to use the SSH URL instead of HTTPS
DOTFILES_REPO="git@github.com:AlexanderBierton/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Starting dotfiles setup..."

# 1. Install GNU Stow & Neovim Dependencies based on the OS package manager
echo "📦 Checking and installing system dependencies..."
if command -v pacman &> /dev/null; then
    echo "🐧 Arch/CachyOS detected. Fetching packages via pacman..."
    # --needed ensures it doesn't reinstall things tha already has!
    sudo pacman -Sy --needed --noconfirm stow neovim tree-sitter tree-sitter-cli nodejs npm rust cargo ripgrep fd gcc make
elif command -v apt-get &> /dev/null; then
    echo "🐧 Debian/Ubuntu detected. Fetching packages via apt..."
    sudo apt-get update
    # Note: Ubuntu repos use 'fd-find' instead of 'fd', and 'build-essential' grabs the C compilers
    sudo apt-get install -y stow neovim nodejs npm cargo ripgrep fd-find build-essential
elif command -v brew &> /dev/null; then
    echo "🍏 macOS detected. Fetching packages via brew..."
    brew install stow neovim tree-sitter node rust ripgrep fd
else
    echo "❌ No supported package manager found (apt, pacman, or brew)."
    exit 1
fi

echo "✅ System dependencies are installed and ready for action."

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

echo "🎉 Setup complete! Thy configs are linked."
echo "💡 Note: Open tmux and press 'Prefix + I' to install thy plugins."
