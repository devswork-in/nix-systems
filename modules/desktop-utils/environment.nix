# Desktop-specific environment variables
{ ... }:

{
  # Desktop-specific environment variables
  home.sessionVariables = {
    # Disable auto-tmux on desktop systems
    TMUX_DISABLE_AUTO_START = "1";
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_TYPE = "x11";
    QT_QPA_PLATFORMTHEME = "gtk";
    # GTK theme variable is set in gtk-config.nix
  };
}