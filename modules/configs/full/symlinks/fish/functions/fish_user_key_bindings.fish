function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
    bind \ck 'e ~/Apps-data/nixpkgs/configs/fish/config.fish;commandline -f repaint'
    bind \cs 'c ~/Study;commandline -f repaint'
    bind \ct 'commandline -i (fzfv)'
    bind \cx yazi
end
