#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# --- Configuration ---
# Replace this with your actual GitHub repository URL
DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "🚀 Starting dotfiles setup..."

# 1. Install GNU Stow based on the OS package manager
if ! command -v stow &> /dev/null; then
    echo "📦 GNU Stow not found. Installing..."
    
    if command -v pacman &> /dev/null; then
        # CachyOS / Arch Linux
        sudo pacman -Sy --noconfirm stow
    elif command -v apt-get &> /dev/null; then
        # Ubuntu / Debian
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v brew &> /dev/null; then
        # macOS (Homebrew)
        brew install stow
    else
        echo "❌ No supported package manager found (apt, pacman, or brew)."
        echo "Please install GNU Stow manually and run this script again."
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
    git pull origin main
else
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# 3. Prevent the "Stow .config Trap"
# If ~/.config doesn't exist, Stow will symlink your entire .config folder 
# instead of the subfolders inside it. This prevents that issue.
echo "📁 Ensuring ~/.config exists..."
mkdir -p "$HOME/.config"

# 4. Link the packages
echo "🔗 Stowing Neovim and Tmux..."
# -v: verbose output
# -R: restow (cleans up old links and re-applies them)
# -t: target directory (your home folder)
stow -v -R -t "$HOME" nvim tmux

echo "🎉 Setup complete! Your configs are linked."
