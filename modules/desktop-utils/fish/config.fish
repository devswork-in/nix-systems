set -gx NNN_PLUG 'f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview;g:!git log;'
set -gx NNN_FIFO '/tmp/nnn.fifo'

# Note: Editor and other generic environment variables are now managed
# through the centralized environment system in modules/essential/configs/common/environment.nix

# Note: Python venv initialization is handled in common fish config
# (modules/essential/configs/common/fish/config.fish)

# Start with custom prompts by default (use Ctrl+P to toggle to starship)
set -g PROMPT_MODE custom

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

