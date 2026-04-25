function __pi_resume
    commandline -r ""
    commandline -f repaint
    
    # Convert current path to Pi's session directory format
    # /home/creator54/loomwork -> --home-creator54-loomwork--
    set -l cwd (pwd)
    set -l session_dir (echo $cwd | sed 's|^/||; s|/$||; s|/|-|g')
    set -l session_dir "--$session_dir--"
    
    # Check if session directory exists with any .jsonl files
    if test -d ~/.pi/agent/sessions/$session_dir
        and count ~/.pi/agent/sessions/$session_dir/*.jsonl >/dev/null 2>&1
        pi -r
    else
        pi
    end
end

function __pi_new
    commandline -r ""
    commandline -f repaint
    pi
end

function fish_user_key_bindings
    # Disable terminal flow control to allow ctrl+s
    stty -ixon 2>/dev/null

    bind '!' bind_bang
    bind '$' bind_dollar
    bind \cs 'fish_search_files; commandline -f repaint'
    bind \cp toggle_prompt
    bind \ck __pi_resume
    bind \cn __pi_new
    bind \ce 'vim .'
end
