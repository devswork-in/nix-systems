# Centralized GTK configuration module
{ pkgs, ... }:

{
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  # Set consistent GTK theme variable
  home.sessionVariables = {
    GTK_THEME = "palenight";
  };




  # GNOME interface settings that complement GTK
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "palenight";
    };
  };
}