#!/usr/bin/env bash

# Exit immediately if any command fails (except for clipboard copy checks)
set -e

echo "🔑 Starting GitHub SSH and Git configuration..."

# 1. Ask for credentials
read -p "Enter your full name (for Git commits): " git_name
read -p "Enter your GitHub email address: " git_email

# 2. Set up basic Git config
echo "⚙️ Configuring Git global settings..."
git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main

# 3. Generate SSH Key (Ed25519 is the modern cryptographic standard)
SSH_FILE="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_FILE" ]; then
    echo "🔐 Generating new Ed25519 SSH key..."
    # We do not skip the passphrase prompt so you can secure it if you wish
    ssh-keygen -t ed25519 -C "$git_email" -f "$SSH_FILE"
else
    echo "✅ SSH key already exists at $SSH_FILE. Skipping generation."
fi

# 4. Start SSH Agent in the background
echo "🤖 Starting ssh-agent..."
eval "$(ssh-agent -s)"

# 5. Add the key to the agent (handling macOS Keychain specifically)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires specific config to store the passphrase in the Keychain
    touch ~/.ssh/config
    if ! grep -q "Host \*" ~/.ssh/config; then
        echo -e "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config
    fi
    ssh-add --apple-use-keychain "$SSH_FILE"
else
    # Linux (Ubuntu/CachyOS)
    ssh-add "$SSH_FILE"
fi

# 6. Attempt to copy the public key to the clipboard
PUB_KEY_FILE="${SSH_FILE}.pub"
echo "📋 Attempting to copy public key to clipboard..."

# Temporarily disable exit-on-error for the clipboard checks
set +e 

if command -v pbcopy &> /dev/null; then
    pbcopy < "$PUB_KEY_FILE"
    echo "✅ Copied to clipboard! (macOS)"
elif command -v wl-copy &> /dev/null; then
    wl-copy < "$PUB_KEY_FILE"
    echo "✅ Copied to clipboard! (Linux/Wayland)"
elif command -v xclip &> /dev/null; then
    xclip -selection clipboard < "$PUB_KEY_FILE"
    echo "✅ Copied to clipboard! (Linux/X11)"
else
    echo "⚠️ Could not copy to clipboard automatically."
    echo "Please copy the following key manually:"
    echo "--------------------------------------------------"
    cat "$PUB_KEY_FILE"
    echo "--------------------------------------------------"
fi

# Re-enable exit-on-error
set -e

# 7. Final instructions
echo ""
echo "🚀 Next steps:"
echo "1. Go to https://github.com/settings/keys"
echo "2. Click 'New SSH key' and give it a title (e.g., 'CachyOS Desktop')."
echo "3. Paste your key (it should already be in your clipboard) and click 'Add SSH key'."
echo "4. Test the connection by running: ssh -T git@github.com"
