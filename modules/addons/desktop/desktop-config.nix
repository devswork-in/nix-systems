# Complete desktop configuration
{ lib, userConfig, ... }:

{
  imports = [
    ../../essential/configs/common/home-manager-base.nix
  ];

  home-manager.users."${userConfig.user.name}" = { ... }: {
    imports = [
      ../../essential/packages/common
      ../../essential/packages/desktop
      ./environment.nix
    ];

      # Desktop-specific configurations (these override essential configs when both are present)
      home.file = {
        # Addon aliases
        ".config/addon-aliases".source = ./addon-aliases;

        # X11 resources
        ".Xresources".source = ./Xresources;

        # Clipboard manager config
        ".config/clipit/clipitrc".source = ./clipit/clipitrc;

        # Fish variables (use mkForce to override essential configs)
        ".config/fish/fish_variables".source = lib.mkForce ./fish/fish_variables;

        # Enhanced fish theme
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

        # Kitty terminal configuration
        ".config/kitty/kitty.conf".source = ./kitty.conf;

        # Icons configuration
        ".icons".source = ./icons;

        # Xinit configuration
        ".xinitrc".source = ./xinitrc;
      };

      # Also extend bash init to include addon aliases
      programs.bash.initExtra = ''
        # Source addon aliases if they exist
        if [ -f ~/.config/addon-aliases ]; then
          source ~/.config/addon-aliases
        fi
      '';

      # Note: Fish is enabled at system level (profiles/base.nix)
      # Desktop-specific fish config is symlinked below
      home.file.".config/fish/config.fish".source = lib.mkForce ./fish/config.fish;
    };
}
