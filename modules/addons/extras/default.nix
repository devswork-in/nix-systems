{ config, pkgs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  user = (import ../../../config.nix { }).userName;
in
{
  home-manager = {
    users."${user}" =
      { ... }:
      {
        home = {
          packages = with pkgs; [
            kitty
            flameshot
            gromit-mpx
          ];
          file = {
            # Create .desktop file for Flameshot to start on login
            ".config/autostart/flameshot.desktop".text = ''
              [Desktop Entry]
              Type=Application
              Exec=flameshot
              Hidden=false
              NoDisplay=false
              X-GNOME-Autostart-enabled=true
              Name=Flameshot
              Comment=Flameshot Screenshot Tool
            '';
            # Create .desktop file for gromit-mpx to start on login
            ".config/autostart/gromit-mpx.desktop".text = ''
              [Desktop Entry]
              Type=Application
              Exec=gromit-mpx
              Hidden=false
              NoDisplay=false
              X-GNOME-Autostart-enabled=true
              Name=Gromit MPX
              Comment=Gromit MPX highlight tool
            '';
            ".kitty/kitty.conf".source = ./kitty.conf;
            ".gromit-mpx.ini".source = ./gromit-mpx.ini;
          };
        };
      };
  };
}
