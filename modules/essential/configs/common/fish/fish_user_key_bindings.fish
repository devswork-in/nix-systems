function fish_user_key_bindings
    # Disable terminal flow control to allow ctrl+s
    stty -ixon 2>/dev/null
    
    bind '!' bind_bang
    bind '$' bind_dollar
    bind \cs 'fish_search_files; commandline -f repaint'
    bind \cp 'toggle_prompt'
end