{ config, pkgs, lib, userConfig, ... }:

{
  # Vanilla GNOME Configuration (without Pop Shell)
  # Import base GNOME configuration
  imports = [
    ./gnome-base.nix
  ];

  # Set default session to GNOME (Wayland)
  services.displayManager.defaultSession = "gnome";

  # Vanilla GNOME extensions
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals
    gnomeExtensions.user-themes
  ];

  # Home Manager configuration for vanilla GNOME
  home-manager.users."${userConfig.user.name}" = {
    home.packages = with pkgs.gnomeExtensions; [
      appindicator
      dash-to-dock
      blur-my-shell
      vitals
      user-themes
    ];

    dconf.settings = {
      # Enable extensions
      "org/gnome/shell".enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "Vitals@CoreCoding.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];

      # Dash to Dock configuration
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "BOTTOM";
        dock-fixed = false;
        autohide = true;
        intellihide = true;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        show-apps-at-top = true;
        show-trash = false;
        show-mounts = false;
        dash-max-icon-size = 48;
        transparency-mode = "DYNAMIC";
        background-opacity = 0.8;
      };

      # Blur My Shell configuration
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 1.0;
        dash-opacity = 0.25;
        sigma = 15;  # Blur amount
        dynamic-blur = true;
      };
      "org/gnome/shell/extensions/blur-my-shell/panel".blur = true;
      "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
        blur = true;
        style-dialogs = 0;
      };

      # Vitals configuration
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_processor_usage_"
          "_memory_usage_"
          "__network-rx_max__"
          "__network-tx_max__"
          "_storage_free_"
          "_system_uptime_"
        ];
        position-in-panel = 2;  # Right side
        show-storage = true;
        show-network = true;
        show-processor = true;
        show-memory = true;
        show-system = true;
        icon-style = 1;  # GNOME style icons
        fixed-widths = true;
      };

      # Window manager settings
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      # Disable Super key overlay
      "org/gnome/mutter" = {
        overlay-key = "";
      };
    };
  };
}
