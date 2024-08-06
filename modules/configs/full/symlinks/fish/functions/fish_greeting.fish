function fish_greeting
    set start_using sx
    test (which sx) >/dev/null; or set start_using startx

    if not pgrep -f $start_using >/dev/null
        if [ $start_using = sx ]
            sx sh .xinitrc >/dev/null 2>&1
        else
            startx >/dev/null 2>&1
        end
        #else if not pgrep -f Hyprland >/dev/null
        #    Hyprland
    end
end
