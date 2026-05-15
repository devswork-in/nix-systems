function nvim --description "Open nvim in a tmux session"
    if not set -q TMUX
        # 1. Start session detached
        tmux new-session -d -s nvim "command nvim $argv" 2>/dev/null
        
        # 2. Apply session-specific settings
        tmux set-option -t nvim status off
        
        # 3. Force source the config to ensure bindings are active
        tmux source-file ~/.tmux.conf 2>/dev/null
        
        # 4. Attach
        tmux attach-session -t nvim
    else
        command nvim $argv
    end
end
