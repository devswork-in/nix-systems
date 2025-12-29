{ config, pkgs, lib, userConfig, inputs, ... }:

{
  # Niri Wayland Compositor Configuration
  # A scrollable-tiling Wayland compositor

  # System-level configuration (minimal)
  programs.niri.enable = true;

  # Keep GDM enabled for display manager selection
  services.xserver.displayManager.gdm.enable = lib.mkForce true;

  # Don't auto-start niri - let user select from display manager
  # environment.loginShellInit = ''
  #   if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  #     exec niri-session
  #   fi
  # '';

  # Wayland packages
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wl-clipboard-rs
    grim
    slurp
    swappy # Screenshot editor (like Flameshot for Wayland)
    swaynotificationcenter # Modern notification daemon
    libnotify # For notifications
    imv # Image viewer (like sxiv for Wayland)
    wlr-randr
    flameshot
    gromit-mpx
    screenkey
    swaybg
    brightnessctl
    playerctl
    blueman # Bluetooth manager with applet
    inputs.vicinae.packages.${pkgs.system}.default
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
    NIXOS_OZONE_WL = "1"; # Hint Electron apps to use Wayland
  };

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    config = {
      common.default = lib.mkForce "gtk";
      niri.default = lib.mkForce "gtk";
    };
    wlr.enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Home Manager configuration
  home-manager.users."${userConfig.user.name}" = {
    home.packages = with pkgs; [
      niri
      fuzzel
      swaylock
      swayidle
      swaynotificationcenter
      waybar
      networkmanagerapplet
      pavucontrol
    ];

    # Notification daemon
    # Notification daemon
    # Notification daemon (Using SwayNC now)

    # Idle management and screen locking
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }
        {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = [{
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }];
    };

    # Note: Niri config.kdl and swappy config are synced via nix-repo-sync
    # See sync-config.nix desktop section (lines 131-154)
  };
}
