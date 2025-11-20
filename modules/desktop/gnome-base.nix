{ config, pkgs, lib, userConfig, ... }:

{
  # Base GNOME Desktop Environment Configuration
  # This module contains common settings shared between vanilla GNOME and Pop Shell
  
  services.xserver = {
    enable = true;
    
    # Display Manager
    displayManager.gdm = {
      enable = true;
      wayland = false;  # Use Xorg instead of Wayland
      autoSuspend = true;
    };
    
    # Desktop Manager
    desktopManager.gnome.enable = true;
  };

  # GNOME Services
  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
  };
  
  # Virtual filesystem support (gvfs is enabled separately)
  services.gvfs.enable = true;

  # Disable conflicting power management
  services.power-profiles-daemon.enable = false;

  # Exclude unnecessary GNOME packages to reduce bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gedit
    gnome-console
    gnome-music
    epiphany      # GNOME Web browser
    geary         # Email client
    evince        # Document viewer (use alternatives)
    gnome-characters
    gnome-maps
    gnome-software
    gnome-contacts
    gnome-weather
    yelp          # Help viewer
    totem         # Video player
    simple-scan
    # GNOME Games
    tali
    iagno
    hitori
    atomix
  ];

  # Essential GNOME packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    dconf-editor
  ];

  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # XDG portal for better app integration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  # Performance optimizations
  environment.variables = {
    # Speed up GNOME Shell animations (0.5 = 2x faster, smoother feel)
    GNOME_SHELL_SLOWDOWN_FACTOR = "0.5";
  };

  # Home Manager base configuration for GNOME
  home-manager.users."${userConfig.user.name}" = {
    # Base dconf settings shared across all GNOME configurations
    dconf.settings = {
      # Mutter (Window Manager) optimizations
      "org/gnome/mutter" = {
        # Enable experimental features for better performance
        experimental-features = [ "scale-monitor-framebuffer" ];
        # Reduce input lag`
        check-alive-timeout = 5000;
        # Enable edge tiling
        edge-tiling = true;
        # Dynamic workspaces
        dynamic-workspaces = true;
      };

      # Desktop interface settings
      "org/gnome/desktop/interface" = {
        enable-animations = true;  # Set to false for maximum performance
        enable-hot-corners = false;
        color-scheme = "prefer-dark";
        
        # Clock settings
        clock-show-weekday = true;
        clock-show-date = true;
        clock-show-seconds = true;
        clock-format = "12h";
        
        # Battery
        show-battery-percentage = true;
      };

      # Window manager preferences
      "org/gnome/desktop/wm/preferences" = {
        focus-mode = "sloppy";
        resize-with-right-button = true;
        # num-workspaces is not used when dynamic-workspaces is enabled
        workspace-names = [];
      };

      # Sound settings
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
      };

      # Session settings
      "org/gnome/desktop/session" = {
        idle-delay = 900;  # 15 minutes
      };

      # Touchpad settings
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
        natural-scroll = true;  # macOS-style scrolling
      };

      # Workspace settings
      "org/gnome/shell/overrides" = {
        workspaces-only-on-primary = false;
      };

      # Night Light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = false;
        night-light-schedule-from = 18.0;
        night-light-schedule-to = 6.0;
        night-light-temperature = 4000;
      };

      # Disable automatic suspend
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };
    };

    # Import GTK configuration
    imports = [
      ./gtk-config.nix
    ];
  };
}
