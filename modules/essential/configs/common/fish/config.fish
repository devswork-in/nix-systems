# Source general aliases
source ~/.config/aliases 2>/dev/null

# Auto-start tmux in interactive shells, except when TMUX_DISABLE_AUTO_START is set
if status is-interactive
  and not set -q TMUX
  and not set -q TMUX_DISABLE_AUTO_START
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

direnv hook fish | source
