# Common environment variables (Bash/Zsh)
# Edited via nix-repo-sync

export EDITOR="nvim"
export VISUAL="nvim"
export GEMINI_API_KEY=AIzaSyCEpr4zQwQS-YJ6XMdVV8pSrmJ5UUc0jAo

# Add user paths
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.bun/bin:$PATH"

# System Identity (Explicitly set for shell)
export NIX_CONFIG_DIR="/etc/nixos"
if [ -z "$NIX_SYSTEM" ]; then
  export NIX_SYSTEM="$(hostname)"
fi
