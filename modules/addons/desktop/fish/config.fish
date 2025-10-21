set -gx NNN_PLUG 'f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview;g:!git log;'
set -gx NNN_FIFO '/tmp/nnn.fifo'

fish_add_path -g $HOME/.local/bin/ $HOME/.npm-global/bin $HOME/.bun/bin

# Note: Editor and other generic environment variables are now managed
# through the centralized environment system in modules/essential/configs/common/environment.nix

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

direnv hook fish | source
starship init fish | source

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

alias x "rm -rf $argv"
alias l 'v (ls | fzf )'
alias d "cd ~/dev"