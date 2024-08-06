{ config, pkgs, lib, ... }:

{
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfig = ''
      pgrep -x sxhkd > /dev/null || sxhkd &
      polybar &
      
      bspc monitor -d 1 2 3 4
      
      bspc config border_width         2
      bspc config window_gap          12
      
      bspc config split_ratio          0.52
      bspc config borderless_monocle   true
      bspc config gapless_monocle      true
      
      bspc rule -a Gimp desktop='^8' state=floating follow=on
      bspc rule -a Chromium desktop='^2'
      bspc rule -a mplayer2 state=floating
      bspc rule -a Kupfer.py focus=on
      bspc rule -a Screenkey manage=off
    '';
  };
  services.sxhkd = {
    enable = true;
    keybindings = {
      "super + Return" = "$TERMINAL";
      "super + shift + Return" = "packages";
      "super + shift + c" = "xdotool getactivewindow windowkill";
      "super + shift + q" = "pkill X";
      "super + x" = "pkill gromit-mpx;or gromit-mpx -a";
      "super + y" = "pidof gromit-mpx && gromit-mpx -y";
      "super + z" = "pidof gromit-mpx && gromit-mpx -z";
      "super + v" = "pidof gromit-mpx && gromit-mpx -v";
      "Print" = "flameshot full -p ~/Screenshots/";
      "super + shift + Print" = "flameshot full -c";
      "super + Print" = "flameshot gui -p ~/Screenshots/";
      "super + p" = "picomSwitch";
      "alt + s" = "feh --bg-fill $(sxiv -o -t ~/Screenshots/)";
      "alt + w" = "feh --bg-fill $(sxiv -o -t $WALLPAPERS)";
      "super + alt + h" = "$TERMINAL -e htop";
      "super + alt + b" = "$BROWSER";
      "super + l" = "betterlockscreen -l";
      "super + shift + w" = "feh --bg-fill --randomize $WALLPAPERS";
      "XF86MonBrightnessDown" = "light -U 10";
      "XF86MonBrightnessUp" = "light -A 10";
      "XF86AudioRaiseVolume" = "amixer set Master 10%+";
      "XF86AudioLowerVolume" = "amixer set Master 10%-";
      "XF86AudioMute" = "amixer set Master toggle";
      "super + alt + t" = "telegram-desktop";
      "super + alt + y" = "ytfzf -t -l --sort";
      "super + ctrl + p" = "poweroff";
      "super + ctrl + r" = "reboot";
      "super + ctrl + h" = "systemctl hybrid-sleep";
    };
  };
}
