# Source general aliases
source ~/.config/aliases 2>/dev/null

# System Identity (Native Fish - ADDED BY REFUSE TO FAIL)
set -gx NIX_CONFIG_DIR "/etc/nixos"
if not set -q NIX_SYSTEM
    set -gx NIX_SYSTEM (hostname)
end


# Source imperative environment variables
# Hierarchy: Common -> Desktop/Server -> System (Hostname)
# Use foreign-env (fenv) to source bash scripts directly
if test -d ~/.config/env
    for target in common desktop server (hostname)
        set -l env_file ~/.config/env/$target.sh
        if test -f $env_file
            fenv source $env_file
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

# Start with custom prompts by default (use Ctrl+P to toggle to starship)
set -g PROMPT_MODE custom

# Git helper functions
function gpull
    git pull origin (git branch | sed 's/^* //') --force
end

function gpush
    if [ -z "$argv" ]
        git push origin (gb | grep -e '*' | cut -d ' ' -f2) --force
    else
        git push origin $argv
    end
end

function ga
    if [ -z "$argv" ]
        git add .
    else
        git add $argv
    end
end

# Python virtual environment management
function activate_venv -d "Activate default Python virtual environment at ~/.venv"
    if test -d $HOME/.venv
        if test -f $HOME/.venv/bin/activate.fish
            source $HOME/.venv/bin/activate.fish
        else
            set -gx VIRTUAL_ENV $HOME/.venv
            set -gx PATH $HOME/.venv/bin $PATH
        end
        echo "Default virtual environment activated: $HOME/.venv"
    else
        echo "Default virtual environment does not exist at $HOME/.venv"
        echo "Creating it with: python -m venv $HOME/.venv"
    end
end

# Convenient aliases
alias x "rm -rf $argv"
alias l 'v (ls | fzf )'
alias d "cd ~/dev"

# Enable direnv
direnv hook fish | source
