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
