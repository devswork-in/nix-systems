{ pkgs, userConfig, ... }:

let
  toGVariantSettings = import ../../lib/toGVariantSettings.nix { lib = pkgs.lib; };
  home = "/home/${userConfig.user.name}";
  theme = pkgs.gruvbox-gtk-theme;
  themePath = "${theme}/share/themes/gruvbox-dark/gtk-4.0";
in {
  environment.systemPackages = with pkgs; [ gruvbox-gtk-theme papirus-icon-theme bibata-cursors ];
  environment.sessionVariables = {
    GTK_THEME = "gruvbox-dark";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [{
    settings = toGVariantSettings { "org/gnome/desktop/interface" = {
      gtk-theme = "gruvbox-dark";
      color-scheme = "prefer-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 24;
    }; };
  }];
  systemd.tmpfiles.rules = [
    "L+ ${home}/.config/gtk-4.0/assets - - - - ${themePath}/assets"
    "L+ ${home}/.config/gtk-4.0/gtk.css - - - - ${themePath}/gtk.css"
    "L+ ${home}/.config/gtk-4.0/gtk-dark.css - - - - ${themePath}/gtk-dark.css"
  ];
}
