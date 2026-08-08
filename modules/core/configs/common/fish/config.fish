# --- vsh configuration start ---
if isatty 1; and begin; not set -q VSH_ACTIVE_TTY; or test "$VSH_ACTIVE_TTY" != (tty); end
    exec vsh
end
# --- vsh configuration end ---

# Source general aliases
source ~/.config/aliases 2>/dev/null

# Source fzf keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
if status is-interactive
    for fzf_path in ~/.nix-profile/share/fzf /run/current-system/sw/share/fzf
        if test -f $fzf_path/key-bindings.fish
            source $fzf_path/key-bindings.fish
            fzf_key_bindings
            break
        end
    end
end

# System Identity (Native Fish - ADDED BY REFUSE TO FAIL)
set -gx NIX_CONFIG_DIR "/etc/nixos"
if not set -q NIX_SYSTEM
    set -gx NIX_SYSTEM $HOSTNAME
end


# Source imperative environment variables (pure fish, no bash spawn)
# Hierarchy: Common -> Desktop/Server -> System (Hostname)
if test -d ~/.config/env
    for target in common desktop server $NIX_SYSTEM doppler
        set -l env_file ~/.config/env/$target.sh
        if test -f $env_file
            for line in (cat $env_file)
                # Skip comments and empty lines
                string match -qr '^\s*(#|$)' $line; and continue
                # Parse export KEY=VALUE
                if string match -qr '^\s*export\s+' $line
                    set -l kv (string replace -r '^\s*export\s+' '' $line)
                    set -l parts (string split -m 1 '=' $kv)
                    if test (count $parts) -eq 2
                        set -l key $parts[1]
                        set -l val (string trim -c '"' -- $parts[2])
                        set val (string trim -c "'" -- $val)
                        set val (string replace -a '$HOME' $HOME -- $val)
                        set val (string replace -a '~' $HOME -- $val)
                        if string match -qr '\$\([^)]+\)' $val
                            set -l cmd (string match -r '\$\(([^)]+)\)' $val)[2]
                            set -l cmd_out ($cmd)
                            set val (string replace -r '\$\([^)]+\)' $cmd_out $val)
                        end
                        if string match -q '*$PATH*' $val
                            set val (string replace -a '$PATH' '' -- $val)
                            set -gx $key $val $$key
                        else
                            set -gx $key $val
                        end
                    end
                end
            end
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

# Auto-activate default Python virtual environment at ~/.venv
# Only activate if no project-specific VIRTUAL_ENV is already set
if not set -q VIRTUAL_ENV
    if test -d $HOME/.venv && test -f $HOME/.venv/bin/activate.fish
        source $HOME/.venv/bin/activate.fish
        # ponytail: activate.fish uses set -gx which exports VIRTUAL_ENV to child
        # processes (nix shells, subshells). Strip the export flag by erasing and
        # re-setting without -x. The variable stays visible to fish/starship for
        # prompt display but does NOT bleed into uv or nix environments.
        set -l _venv $VIRTUAL_ENV
        set -e VIRTUAL_ENV
        set -e VIRTUAL_ENV_PROMPT
        set -g VIRTUAL_ENV $_venv
    end
end

# Desktop-specific settings (NNN file manager)
set -gx NNN_PLUG 'f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview;g:!git log;'
set -gx NNN_FIFO '/tmp/nnn.fifo'

set -l starship_bin (type -p starship)
if test -n "$starship_bin"
    if not test -f ~/.cache/starship_init.fish; or test $starship_bin -nt ~/.cache/starship_init.fish
        starship init fish > ~/.cache/starship_init.fish 2>/dev/null
    end
    source ~/.cache/starship_init.fish
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



# Added by Antigravity CLI installer
set -gx PATH "/home/creator54/.local/bin" $PATH


# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# kimi-code
fish_add_path -g "/home/creator54/.kimi-code/bin"
