function nvim --description "Open nvim in a tmux session"
    if not set -q TMUX
        # 1. Start session detached so we can apply settings before seeing it
        tmux new-session -d -s nvim "command nvim $argv" 2>/dev/null
        
        # 2. Force status off globally for this session
        tmux set-option -t nvim status off
        
        # 3. Attach
        tmux attach-session -t nvim
    else
        command nvim $argv
    end
end
