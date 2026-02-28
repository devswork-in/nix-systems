function fish_user_key_bindings
    # Disable terminal flow control to allow ctrl+s
    stty -ixon 2>/dev/null

    # fzf keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
    fzf_key_bindings

    bind '!' bind_bang
    bind '$' bind_dollar
    bind \cs 'fish_search_files; commandline -f repaint'
    bind \cp toggle_prompt
    bind \ce 'vim .'
end

