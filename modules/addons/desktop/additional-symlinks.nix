# Additional application configs and extensions
{ config, pkgs, ... }:

{
  # Additional aliases for addon-specific functionality
  home.file.".config/addon-aliases".source = ./addon-aliases;

  # Extend shell init to include addon aliases
  programs.bash.initExtra = ''
    # Source addon aliases if they exist
    if [ -f ~/.config/addon-aliases ]; then
      source ~/.config/addon-aliases
    fi
  '';

  # For fish, we'll add functions that extend the shell
  programs.fish = {
    enable = true;
    
    interactiveShellInit = ''
      # Source addon aliases if they exist
      if test -f ~/.config/addon-aliases
        source ~/.config/addon-aliases
      end
    '';
  };

  home.file = {
    # X11 resources
    ".Xresources".source = ./Xresources;

    # Clipboard manager config
    ".config/clipit/clipitrc".source = ./clipit/clipitrc;


    
    # Enhanced fish theme (this adds to fish functionality without replacing core functions)
    ".config/fish/mzish/LICENSE".source = ./fish/mzish/LICENSE;
    ".config/fish/mzish/README.md".source = ./fish/mzish/README.md;
    ".config/fish/mzish/fish_prompt.fish".source = ./fish/mzish/fish_prompt.fish;
    ".config/fish/mzish/fish_right_prompt.fish".source = ./fish/mzish/fish_right_prompt.fish;
    
    # Gromit-mpx configuration
    ".config/gromit-mpx.ini".source = ./gromit-mpx.ini;

    # Flameshot configuration
    ".config/flameshot/flameshot.ini".source = ./flameshot/flameshot.ini;

    # XPLR configuration
    ".config/xplr/init.lua".source = ./xplr/init.lua;

    # MPV configuration and scripts
    ".config/mpv/scripts/youtube-quality-osc.lua".source = ./mpv/scripts/youtube-quality-osc.lua;
    ".config/mpv/scripts/youtube-quality.lua".source = ./mpv/scripts/youtube-quality.lua;
    ".config/mpv/script-opts/youtube-quality.conf".source = ./mpv/youtube-quality.conf;
    ".config/mpv/README.md".source = ./mpv/README.md;



    # Kitty terminal configuration (this would override if imported after essential)
    ".config/kitty/kitty.conf".source = ./kitty.conf;

    # Icons configuration
    ".icons".source = ./icons;

    # Xinit configuration
    ".xinitrc".source = ./xinitrc;
  };
}