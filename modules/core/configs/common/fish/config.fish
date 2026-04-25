# Source general aliases
source ~/.config/aliases 2>/dev/null

# Source fzf keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
for fzf_path in ~/.nix-profile/share/fzf /run/current-system/sw/share/fzf
    if test -f $fzf_path/key-bindings.fish
        source $fzf_path/key-bindings.fish
        fzf_key_bindings
        break
    end
end

# System Identity (Native Fish - ADDED BY REFUSE TO FAIL)
set -gx NIX_CONFIG_DIR "/etc/nixos"
if not set -q NIX_SYSTEM
    set -gx NIX_SYSTEM (hostname)
end


# Source imperative environment variables (pure fish, no bash spawn)
# Hierarchy: Common -> Desktop/Server -> System (Hostname)
if test -d ~/.config/env
    for target in common desktop server (hostname) doppler
        set -l env_file ~/.config/env/$target.sh
        if test -f $env_file
            while read -l line
                # Skip comments and empty lines
                string match -qr '^\s*#' $line; and continue
                string match -qr '^\s*$' $line; and continue
                # Parse export KEY=VALUE
                if string match -qr '^\s*export\s+' $line
                    set -l kv (string replace -r '^\s*export\s+' '' $line)
                    set -l key (string split -m 1 '=' $kv)[1]
                    set -l val (string split -m 1 '=' $kv)[2]
                    # Strip surrounding quotes
                    set val (string trim -c '"' -- $val)
                    set val (string trim -c "'" -- $val)
                    # Expand $HOME
                    set val (string replace -a '$HOME' $HOME -- $val)
                    set val (string replace -a '~' $HOME -- $val)
                    # Expand $(command) via fish command substitution
                    if string match -qr '\$\([^)]+\)' $val
                        set -l cmd (string match -r '\$\(([^)]+)\)' $val)[2]
                        set -l cmd_out ($cmd)
                        set val (string replace -r '\$\([^)]+\)' $cmd_out $val)
                    end
                    # Handle PATH append: $HOME/...:$PATH
                    if string match -q '*$PATH*' $val
                        set val (string replace -a '$PATH' '' -- $val)
                        set -gx $key $val $$key
                    else
                        set -gx $key $val
                    end
                end
            end < $env_file
        end
    end
end

# Auto-start tmux in interactive shells (servers only)
# Set TMUX_AUTO_START=1 to enable on desktop systems
if status is-interactive
    and not set -q TMUX
    and set -q TMUX_AUTO_START
    if tmux ls
        exec tmux attach
    else
        exec tmux
    end
end

# Auto-create and activate default Python virtual environment
if test -d $HOME/.venv && test -f $HOME/.venv/bin/activate.fish
    # Virtual environment exists and is valid, activate it
    source $HOME/.venv/bin/activate.fish
else
    # Virtual environment doesn't exist or is invalid, create and activate it
    if test -d $HOME/.venv
        # If directory exists but no activate.fish, remove it and recreate
        echo "Recreating invalid virtual environment..."
        rm -rf $HOME/.venv
    else
        echo "Creating default Python virtual environment..."
    end

    # Create the virtual environment
    python -m venv $HOME/.venv

    # Activate it if creation was successful
    if test -f $HOME/.venv/bin/activate.fish
        source $HOME/.venv/bin/activate.fish
    else
        echo "Warning: Could not create virtual environment properly"
    end
end

# Desktop-specific settings (NNN file manager)
set -gx NNN_PLUG 'f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview;g:!git log;'
set -gx NNN_FIFO '/tmp/nnn.fifo'

# Start with starship prompt by default (use Ctrl+P to toggle to custom)
if command -v starship >/dev/null 2>&1
    eval (starship init fish)
    set -g PROMPT_MODE starship
else
    set -g PROMPT_MODE custom
end

# Git helper functions (lazy-loaded from ~/.config/fish/functions/)
# gpull, gpush, ga, activate_venv

# Convenient aliases
alias x "rm -rf $argv"
alias l 'v (ls | fzf )'
alias d "cd ~/dev"



