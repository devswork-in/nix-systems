# Centralized GTK configuration module — Gruvbox unified theme
{ pkgs, config, ... }:

let
  gruvbox-theme = pkgs.gruvbox-gtk-theme;
  themeName = "gruvbox-dark";
in
{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = themeName;
      package = gruvbox-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };

    gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
  };

  # GTK 4 theme symlinks
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Set consistent GTK theme variable
  home.sessionVariables = { GTK_THEME = themeName; };

  # GNOME interface settings that complement GTK
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = themeName;
      color-scheme = "prefer-dark";
      icon-theme = "Papirus-Dark";
    };
  };
}
