# Common environment variables (Bash/Zsh)
# Edited via nix-repo-sync

export EDITOR="nvim"
export VISUAL="nvim"

# Add user paths
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.bun/bin:$PATH"

# System Identity (Explicitly set for shell)
export NIX_CONFIG_DIR="/etc/nixos"
if [ -z "$NIX_SYSTEM" ]; then
    export NIX_SYSTEM="$(hostname)"
fi

# System Identity (Explicitly set for shell)
export NIX_CONFIG_DIR="/etc/nixos"
if [ -z "$NIX_SYSTEM" ]; then
    export NIX_SYSTEM="$(hostname)"
fi
