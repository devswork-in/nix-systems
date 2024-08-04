{
  pkgs,
  home-manager,
  ...
}:
let
  user = (import ./../../../config.nix {}).userName;
  gnomeExtensionsList = with pkgs.gnomeExtensions; [
    user-themes
    unite-shell
    blur-my-shell
    pop-shell
  ];
in
{
  # ---- Home Configuration ----
  home-manager.users.${user} = {

    home.packages = gnomeExtensionsList;

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

    home.sessionVariables.GTK_THEME = "palenight";
  
    dconf.settings = {
      "org/gnome/shell".enabled-extensions =
        (map (extension: extension.extensionUuid) gnomeExtensionsList)
        ++ [
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "unite-shell@gnome-shell-extensions.hardpixel.github.com"
          #"native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
#
      "org/gnome/shell".disabled-extensions = [ ];

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;

        gtk-theme = "palenight";

        ## Clock
        clock-show-weekday = true;
        clock-show-date = true;
	clock-show-seconds = true;
	clock-format = "12h";
      };

      # Keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>q";
        command = "foot  > /dev/null 2>&1 &";
        name = "open-terminal";
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "<Shift><Super>s" ];
      };

      "org/gnome/desktop/wm/keybindings" = {
        toggle-message-tray = "disabled";
        close = [ "<Super><Shift>c" ];
        maximize = "<Super>f";
        minimize = "<Super><Shift>f";
        move-to-monitor-down = "disabled";
        move-to-monitor-left = "disabled";
        move-to-monitor-right = "disabled";
        move-to-monitor-up = "disabled";
        move-to-workspace-down = "disabled";
        move-to-workspace-up = "disabled";
        move-to-corner-nw = "disabled";
        move-to-corner-ne = "disabled";
        move-to-corner-sw = "disabled";
        move-to-corner-se = "disabled";
        move-to-side-n = "disabled";
        move-to-side-s = "disabled";
        move-to-side-e = "disabled";
        move-to-side-w = "disabled";
        move-to-center = "disabled";
        toggle-maximized = "disabled";
        unmaximize = "disabled";
      };

      "org/gnome/shell/extensions/pop-shell" = {
        tile-by-default = true;
      };

      # Configure blur-my-shell
      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.85;
        dash-opacity = 0.25;
        sigma = 15; # Sigma means blur amount
        static-blur = true;
      };
      "org/gnome/shell/extensions/blur-my-shell/panel".blur = true;
      "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
        blur = true;
        style-dialogs = 0;
      };

      # Configure Pano
      "org/gnome/shell/extensions/pano" = {
        global-shortcut = [ "<Super>comma" ];
        incognito-shortcut = [ "<Shift><Super>less" ];
      };

      # Set the default window for primary applications
      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [ "firefox.desktop:1" ];
      };

      # The open applications bar
      "org/gnome/shell/extensions/window-list" = {
        grouping-mode = "always";
        show-on-all-monitors = true;
        display-all-workspaces = true;
      };
    };
  };

  # ---- System Configuration ----
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit
    ])
    ++ (with pkgs.gnome; [
      gnome-music
      epiphany
      geary
      evince
      gnome-characters
      totem
      tali
      iagno
      hitori
      atomix
    ]);
  services.power-profiles-daemon.enable = false;
}
