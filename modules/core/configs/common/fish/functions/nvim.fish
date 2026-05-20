function nvim --description "Open nvim in a tmux session"
    if not set -q TMUX
        # Generate a unique session name based on the current directory path
        set -l pwd_hash (pwd | string replace -a '/' '-' | string replace -a '.' '-' | string trim -l -c '-')
        if test -z "$pwd_hash"
            set pwd_hash "root"
        end
        set -l session_name "nvim-$pwd_hash"

        # 1. Start session detached if it doesn't exist
        if not tmux has-session -t "$session_name" 2>/dev/null
            tmux new-session -d -s "$session_name" "command nvim $argv" 2>/dev/null
            
            # 2. Apply session-specific settings
            tmux set-option -t "$session_name" status off
            
            # 3. Force source the config to ensure bindings are active
            tmux source-file ~/.tmux.conf 2>/dev/null
        end
        
        # 4. Attach
        tmux attach-session -t "$session_name"
    else
        command nvim $argv
    end
end
