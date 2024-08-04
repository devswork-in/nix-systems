{ pkgs, home-manager, ... }:

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
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];

      "org/gnome/shell".disabled-extensions = [];

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
        binding = "<Super><Shift>Return";
        command = "kitty";
        name = "kitty-terminal";
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-5 = [ "<Super>5" ];
        switch-to-workspace-6 = [ "<Super>6" ];
        switch-to-workspace-7 = [ "<Super>7" ];
        switch-to-workspace-8 = [ "<Super>8" ];
        switch-to-workspace-9 = [ "<Super>9" ];
        switch-to-workspace-10 = [ "<Super>0" ];

        move-to-workspace-1 = [ "<Super><Shift>1" ];
        move-to-workspace-2 = [ "<Super><Shift>2" ];
        move-to-workspace-3 = [ "<Super><Shift>3" ];
        move-to-workspace-4 = [ "<Super><Shift>4" ];
        move-to-workspace-5 = [ "<Super><Shift>5" ];
        move-to-workspace-6 = [ "<Super><Shift>6" ];
        move-to-workspace-7 = [ "<Super><Shift>7" ];
        move-to-workspace-8 = [ "<Super><Shift>8" ];
        move-to-workspace-9 = [ "<Super><Shift>9" ];
        move-to-workspace-10 = [ "<Super><Shift>0" ];

        show-screenshot-ui = [ "<Shift><Super>s" ];

        # Additional GNOME Shell Keybindings
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

