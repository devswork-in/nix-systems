function nvim --description "Open nvim in a tmux session"
    if not set -q TMUX
        # Generate a unique session name based on the current directory path
        set -l pwd_hash (pwd | string replace -a '/' '-' | string replace -a '.' '-' | string trim -l -c '-')
        if test -z "$pwd_hash"
            set pwd_hash "root"
        end
        set -l session_name "nvim-$pwd_hash"
        set -l runtime_dir "$XDG_RUNTIME_DIR"
        if test -z "$runtime_dir"
            set runtime_dir "/tmp/nvim-"(id -u)
            mkdir -p -m 700 "$runtime_dir"
        end
        set -l socket_hash (printf %s (pwd) | sha256sum | cut -d ' ' -f1)
        set -l nvim_socket "$runtime_dir/nvim-$socket_hash.sock"

        # 1. Start session detached if it doesn't exist
        if not tmux has-session -t "$session_name" 2>/dev/null
            set -l nvim_command (string join -- ' ' (string escape -- command nvim --listen "$nvim_socket" $argv))
            tmux new-session -d -s "$session_name" "$nvim_command" 2>/dev/null
            
            # 2. Apply session-specific settings
            tmux set-option -t "$session_name" status off
            
            # 3. Force source the config to ensure bindings are active
            tmux source-file ~/.tmux.conf 2>/dev/null
        else if test (count $argv) -gt 0
            if command nvim --server "$nvim_socket" --remote-expr 1 >/dev/null 2>&1
                set -l remote_args $argv
                set -l remote_command
                if string match -q '+*' -- "$remote_args[1]"
                    set remote_command (string sub -s 2 -- "$remote_args[1]" | string replace -a "'" "''")
                    set -e remote_args[1]
                end

                if test (count $remote_args) -gt 0
                    command nvim --server "$nvim_socket" --remote $remote_args
                end
                if test -n "$remote_command"
                    command nvim --server "$nvim_socket" --remote-expr "execute('$remote_command')" >/dev/null
                end
            else
                echo "nvim: existing session cannot receive files; restart it once" >&2
            end
        end
        
        # 4. Attach
        tmux attach-session -t "$session_name"
    else
        command nvim $argv
    end
end
