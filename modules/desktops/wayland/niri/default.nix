{ config, pkgs, lib, userConfig, ... }:

{
  # Niri Wayland Compositor Configuration
  # A scrollable-tiling Wayland compositor
  
  # System-level configuration (minimal)
  programs.niri.enable = true;
  
  # Disable GDM, use console login
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
  
  # Auto-start niri on login (optional - user can manually start with 'niri-session')
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec niri-session
    fi
  '';
  
  # Wayland packages
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wl-clipboard-rs
    grim
    slurp
    wlr-randr
  ];
  
  # Wayland environment variables
  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  
  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = [ "gtk" ];
    wlr.enable = true;
  };
  
  # Home Manager configuration
  home-manager.users."${userConfig.user.name}" = {
    home.packages = with pkgs; [
      niri
      fuzzel
      swaylock
      swayidle
      mako
      waybar
      networkmanagerapplet
      pavucontrol
    ];
    
    # Notification daemon
    services.mako = {
      enable = true;
      defaultTimeout = 5000;
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#89b4fa";
      borderRadius = 10;
      borderSize = 2;
    };
    
    # Idle management and screen locking
    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      ];
    };
  };
}
