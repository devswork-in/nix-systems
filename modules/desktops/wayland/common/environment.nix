{ pkgs, lib, ... }:

{
  # Wayland-wide environment variables
  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    NIXOS_OZONE_WL = "1";
  };

  # XWayland support (common for all Wayland compositors)
  services.xserver.enable = true;

  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    config = {
      common = {
        default = lib.mkForce [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
    wlr.enable = true;
  };

  # Enable dconf (required for GTK apps like Bottles)
  programs.dconf.enable = true;

  # System packages needed for Wayland
  environment.systemPackages = with pkgs; [
    # Icons for GTK apps (fixes missing icons in Bottles/etc)
    adwaita-icon-theme

    xwayland-satellite
    wlogout
    wl-clipboard
    wl-clipboard-rs
    grim
    slurp
    swappy
    libnotify
  ];
}
