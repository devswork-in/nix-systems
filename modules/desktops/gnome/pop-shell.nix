{ pkgs, home-manager, userConfig, lib, inputs, ... }:

{
  # Pop Shell Configuration
  # Import base GNOME configuration
  imports = [ ./base.nix ];

  # Pop Shell specific configuration
  config = let
    user = userConfig.user.name;
    screenshotsPathRaw = userConfig.desktop.screenshotsPath or "~/Screenshots";
    # Expand ~ to actual home directory
    screenshotsPath = if lib.hasPrefix "~/" screenshotsPathRaw then
      "/home/${user}/${lib.removePrefix "~/" screenshotsPathRaw}"
    else
      screenshotsPathRaw;

    # ref:
    # https://github.com/flameshot-org/flameshot/issues/3365#issuecomment-1868580715
    # https://flameshot.org/docs/guide/wayland-help/
    flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui"
      "${pkgs.flameshot}/bin/flameshot gui -c";
    flameshot-gui-path = pkgs.writeShellScriptBin "flameshot-gui-path"
      "${pkgs.flameshot}/bin/flameshot gui -p ${screenshotsPath}";
    flameshot-full = pkgs.writeShellScriptBin "flameshot-full"
      "${pkgs.flameshot}/bin/flameshot full -p ${screenshotsPath}";
    local-scripts = pkgs.writeShellScriptBin "local-scripts" ''
      selected_script=$(${pkgs.coreutils}/bin/ls /home/${user}/.local/bin | ${pkgs.rofi}/bin/rofi -dmenu)
      if [ -n "$selected_script" ]; then
        bash -c /home/${user}/.local/bin/"$selected_script"
      else
        echo "No script selected. Exiting."
      fi
    '';

    kill-session = pkgs.writeShellScriptBin "kill-session"
      "${pkgs.systemd}/bin/loginctl kill-session $(${pkgs.systemd}/bin/loginctl | ${pkgs.coreutils}/bin/coreutils --coreutils-prog=tail -n +2| ${pkgs.findutils}/bin/xargs| ${pkgs.coreutils}/bin/coreutils --coreutils-prog=cut -d ' ' -f1)";
    lock-session = pkgs.writeShellScriptBin "lock-session"
      "${pkgs.systemd}/bin/loginctl lock-session $(${pkgs.systemd}/bin/loginctl | ${pkgs.coreutils}/bin/coreutils --coreutils-prog=tail -n +2| ${pkgs.findutils}/bin/xargs| ${pkgs.coreutils}/bin/coreutils --coreutils-prog=cut -d ' ' -f1)";

    togglePanelFreeScript = pkgs.writeShellScriptBin "toggle-panel-free" ''
      #!/usr/bin/env bash

      EXTENSION_UUID="panel-free@fthx"

      # Get current enabled extensions
      ENABLED=$(${pkgs.glib}/bin/gsettings get org.gnome.shell enabled-extensions)

      # Check if extension is currently enabled
      if echo "$ENABLED" | ${pkgs.gnugrep}/bin/grep -q "$EXTENSION_UUID"; then
        # Disable the extension (show top bar)
        ${pkgs.gnome-shell}/bin/gnome-extensions disable "$EXTENSION_UUID"
      else
        # Enable the extension (hide top bar)
        ${pkgs.gnome-shell}/bin/gnome-extensions enable "$EXTENSION_UUID"
      fi
    '';

    disableFavoriteAppShortcuts =
      pkgs.writeShellScript "disable-favorite-app-shortcuts" ''
        gsettings set org.gnome.shell.keybindings switch-to-application-1 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-2 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-3 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-4 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-5 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-6 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-7 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-8 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-9 "@as []"
        gsettings set org.gnome.shell.keybindings switch-to-application-10 "@as []"
      '';

    gnomeExtensionsList = with pkgs.gnomeExtensions; [
      user-themes
      unite-shell
      blur-my-shell
      pop-shell
      panel-free
      no-overview
      window-title-is-back
      workspace-switcher-manager
      vitals # System monitor with disk usage and uptime
    ];
  in {
    # ---- Home Configuration ----
    home-manager.users.${user} = {
      home.packages = gnomeExtensionsList;
      home.file = {
        # Create .desktop file for dconf settings to be applied at login
        ".config/autostart/dconf-settings.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Exec=bash -c "dconf write /org/gnome/shell/extensions/pop-shell/active-hint-border-radius '@u 12'"
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name=dconf Settings
          Comment=Apply dconf settings at login
        '';
        ".config/autostart/disable-favorite-apps.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Exec=${disableFavoriteAppShortcuts}
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name=Disable Favorite App Shortcuts
          Comment=Disable GNOME Shell favorite app shortcuts
        '';
        ".config/autostart/vicinae-server.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Exec=${
            inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
          }/bin/vicinae server
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name=Vicinae Server
          Comment=Start Vicinae application launcher server
        '';
        ".config/pop-shell/config.json".text = builtins.toJSON {
          float = [ { class = "Vicinae"; } { class = "vicinae"; } ];
        };
      };

      imports = [ ../../desktop-utils/gtk-config.nix ];

      dconf.settings = {
        #check extensions uuids via gnome-extensions list
        "org/gnome/shell".enabled-extensions =
          (map (extension: extension.extensionUuid) gnomeExtensionsList) ++ [
            "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
            "unite-shell@gnome-shell-extensions.hardpixel.github.com"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "gsconnect@andyholmes.github.io"
            "no-overview@fthx"
            "panel-free@fthx"
            "window-title-is-back@fthx"
            "workspace-switcher-manager@G-dH.github.com"
            "drive-menu@gnome-shell-extensions.gcampax.github.com"
          ];

        "org/gnome/shell".disabled-extensions = [
          "system-monitor@gnome-shell-extensions.gcampax.github.com" # Replaced with Vitals
        ];

        "org/gnome/desktop/background" = {
          picture-uri = "file://${./wallpaper.jpg}";
          picture-uri-dark = "file://${./wallpaper.jpg}";
        };

        # If not disabled <Super>num keys will open pinned favourite applications
        "org/gnome/shell".favorite-apps = "@as []";

        # Checkout gsettings get org.gnome.desktop.interface <option>
        # gsettings set org.gnome.desktop.interface <option> true/false
        "org/gnome/desktop/interface" = {
          enable-animations = true;
          color-scheme = "prefer-dark";
          enable-hot-corners = false;

          ## Clock
          clock-show-weekday = true;
          clock-show-date = true;
          clock-show-seconds = true;
          clock-format = "12h";

          # Battery
          show-battery-percentage = true;
        };

        "org/gnome/desktop/wm/preferences" = { focus-mode = "sloppy"; };

        "org/gnome/desktop/sound" = { allow-volume-above-100-percent = true; };

        # Keybindings
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom17/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18/"
          ];

          # Set default screenshot keybindings to empty strings
          #screenshot = "";
          #screenshot-window = "";
          #screenshot-area = "";
        };

        # Disable the default <Super>num keybindings
        # "org/gnome/shell.keybindings" = {
        #   switch-to-application-1 = "@as []";
        #   switch-to-application-2 = "@as []";
        #   switch-to-application-3 = "@as []";
        #   switch-to-application-4 = "@as []";
        #   switch-to-application-5 = "@as []";
        #   switch-to-application-6 = "@as []";
        #   switch-to-application-7 = "@as []";
        #   switch-to-application-8 = "@as []";
        #   switch-to-application-9 = "@as []";
        #   switch-to-application-10 = "@as []";  # Added for completeness
        # };

        # Disables the default screenshot interface
        "org/gnome/shell/keybindings" = { show-screenshot-ui = [ ]; };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
          {
            binding = "<Super><Shift>Return";
            command = "kitty";
            name = "kitty-terminal";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
          {
            binding = "Print";
            command = "${flameshot-full}/bin/flameshot-full";
            name = "Full Screenshot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
          {
            binding = "<Super>Print";
            command = "${flameshot-gui-path}/bin/flameshot-gui-path";
            name = "GUI Screenshot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" =
          {
            binding = "<Super><Shift>Print";
            command = "${flameshot-gui}/bin/flameshot-gui";
            name = "Clipboard Screenshot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" =
          {
            binding = "<Alt>x";
            command = "bash -c 'pkill gromit-mpx || gromit-mpx -a'";
            name = "Toggle Gromit-mpx";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" =
          {
            binding = "<Alt>y";
            command = "bash -c 'pidof gromit-mpx && gromit-mpx -y'";
            name = "Gromit-mpx Yellow";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" =
          {
            binding = "<Alt>z";
            command = "bash -c 'pidof gromit-mpx && gromit-mpx -z'";
            name = "Gromit-mpx Zoom";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" =
          {
            binding = "<Alt>v";
            command = "bash -c 'pidof gromit-mpx && gromit-mpx -v'";
            name = "Gromit-mpx Vertical";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" =
          {
            binding = "<Super><Control>r";
            command = "reboot";
            name = "Reboot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" =
          {
            binding = "<Super><Control>p";
            command = "poweroff";
            name = "Poweroff";
          };

        # Keybinding to toggle panel-free extension
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" =
          {
            binding = "<Super>b";
            command = "${togglePanelFreeScript}/bin/toggle-panel-free";
            name = "Toggle Panel-Free";
          };

        # Keybind to Kill Session
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" =
          {
            binding = "<Super><Shift>q";
            command = "${kill-session}/bin/kill-session";
            name = "Kill logged in session";
          };

        # Keybind to lock current session
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12" =
          {
            binding = "<Super>q";
            command = "${lock-session}/bin/lock-session";
            name = "Lock logged in session";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13" =
          {
            name = "Run Rofi Script";
            command = "${local-scripts}/bin/local-scripts";
            binding = "<Alt>Return";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14" =
          {
            name = "Change Wallpapers";
            command = ''
              bash -c '
                # Create temporary variables for the paths
                WALLPAPER_PATH=$(${pkgs.findutils}/bin/find /home/${user}/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | ${pkgs.coreutils}/bin/shuf -n 1)
                DARK_WALLPAPER_PATH=$(${pkgs.findutils}/bin/find /home/${user}/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | ${pkgs.coreutils}/bin/shuf -n 1)
                
                # Set the wallpapers
                ${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
                ${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.background picture-uri-dark "file://$DARK_WALLPAPER_PATH"
              '
            '';
            binding = "<Super><Shift>w";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15" =
          {
            name = "Run Screenkeys";
            command = "screenkey --no-systray -t 0.4 --opacity 0.0";
            binding = "<Alt>k";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16" =
          {
            name = "Kill Screenkeys";
            command = "pkill screenkey";
            binding = "<Alt><Shift>k";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom17" =
          {
            name = "Refresh Page on Browser";
            command = ''
              bash -c '${pkgs.xdotool}/bin/xdotool key ctrl+r'
            '';
            binding = "<Super>r";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18" =
          {
            name = "Launch Vicinae";
            command = "${
                inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/vicinae toggle";
            binding = "<Super>slash";
          };

        "org/gnome/desktop/wm/preferences".button-layout = ":";

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
          switch-to-workspace-left = [ "<Control>Left" ];
          switch-to-workspace-right = [ "<Control>Right" ];
          switch-to-workspace-up = [ "<Control>Page_Up" ];
          switch-to-workspace-down = [ "<Control>Page_Down" ];

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
          toggle-fullscreen = [ "<Super>f" ];
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

        # Disable mutter keybinds
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [ ];
          toggle-tiled-right = [ ];
        };

        # Configure blur-my-shell
        "org/gnome/shell/extensions/blur-my-shell" = {
          brightness = 1;
          dash-opacity = 0.25;
          sigma = 15; # Sigma means blur amount
          dynamic-blur = true;
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

        # Night Light Configuration
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule = "custom";
          night-light-schedule-custom = [ "18:00" "06:00" ];
          night-light-temperature =
            4000; # Adjust the color temperature as needed
        };

        # Workspace switch pop-up Configuration
        # Note: workspace-switcher-manager can sometimes interfere with dynamic workspaces
        # If dynamic workspaces aren't working, try removing this extension from gnomeExtensionsList
        "org/gnome/shell/extensions/workspace-switcher-manager" = {
          popup-visibility = 0; # 0 = hidden, 1 = always show
        };

        # Pop Shell Extension settings
        "org/gnome/shell/extensions/pop-shell" = {
          active-hint = true;
          # does not work, ref: https://github.com/pop-os/shell/issues/1582
          # as always gets formatted incorrectly
          # active-hint-border-radius = 12;
          tile-by-default = true;
          # Disable Pop Shell launcher to use Vicinae instead
          activate-launcher = [ ];
        };

        # Unite extension settings (if available via dconf)
        # Check available extensions path via dconf list /org/gnome/shell/extensions/
        # Check inside via dconf like dconf list /org/gnome/shell/extensions/unite/
        "org/gnome/shell/extensions/unite" = {
          hide-window-titlebars = true;
          hide-activities-button = "never"; # Adjust based on preference
          hide-app-menu-icon = true; # Adjust based on preference
          show-appmenu-button = false; # Adjust based on preference
          show-window-title = true; # Ensure window title is hidden
          desktop-name-text = ""; # Optionally set the desktop name text
          extend-left-box = true; # Adjust based on preference
          reduce-panel-spacing = true; # Adjust based on preference
          restrict-to-primary-screen = false; # Adjust based on preference
          show-desktop-name = false; # Adjust based on preference
          show-legacy-tray = false; # Adjust based on preference
          use-activities-text = false; # Adjust based on preference
          enable-titlebar-actions = false; # Adjust based on preference
        };

        # Disable automatic suspend
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-type = "nothing";
        };

        # Disable Super key (Overlay Key) and configure workspaces
        "org/gnome/mutter" = {
          overlay-key = "";
          dynamic-workspaces = true; # Auto-create workspaces as needed
          edge-tiling = true; # Enable edge tiling
        };

        # Workspace settings
        # Note: When dynamic-workspaces is true, num-workspaces is ignored
        # Dynamic workspaces will auto-create/remove workspaces as needed
        "org/gnome/desktop/wm/preferences" = {
          # num-workspaces is not used with dynamic workspaces
          workspace-names = [ ]; # Let GNOME auto-name them
        };

        # Enable touchpad gestures for workspace switching
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
          natural-scroll = true; # Reverse scrolling direction (macOS-style)
        };

        # Gesture settings for workspace switching
        "org/gnome/shell/overrides" = {
          workspaces-only-on-primary = false; # Show workspaces on all monitors
        };

        # Vitals Extension Configuration
        "org/gnome/shell/extensions/vitals" = {
          hot-sensors = [
            "_processor_usage_"
            "_memory_usage_"
            "__network-rx_max__"
            "__network-tx_max__"
            "_storage_free_"
            "_system_uptime_"
          ];
          position-in-panel =
            1; # 0 = left, 1 = center, 2 = right (center to be closer to time)
          show-storage = true;
          show-network = true;
          show-processor = true;
          show-memory = true;
          show-system = true;
          menu-centered = false;
          alphabetize = false;
          hide-zeros = false;
          use-higher-precision = false;
          icon-style =
            1; # 0 = original, 1 = GNOME, 2 = symbolic (smaller, cleaner icons)
          fixed-widths = true;
          hide-icons = false;
        };

        # Prevent Evolution services from auto-starting
        "org/gnome/evolution-data-server" = { autostart = false; };
      };
    };

    # ---- Pop Shell Specific System Configuration ----

    # Set default session to GNOME (Wayland by default in NixOS 25.xx)
    # Note: Pop Shell works on both X11 and Wayland
    services.displayManager.defaultSession = "gnome";

    # KDE Connect (GSConnect)
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    # Pop Shell dependencies
    environment.systemPackages = with pkgs; [
      rofi
      pop-launcher
      inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Apply overlay for panel-free extension v10
    nixpkgs.overlays = [ (import ./panel-free-overlay.nix) ];

    # ---- Service Optimization ----
    # These optimizations are specific to GNOME/Pop Shell and are always enabled
    # when using this desktop environment

    # Disable Evolution packages (not using Evolution email client)
    environment.gnome.excludePackages = with pkgs; [ evolution ];

    # Disable Evolution data server service (this is a service, not a package)
    services.gnome.evolution-data-server.enable = lib.mkForce false;

    # Disable unused GNOME Settings Daemon services
    systemd.user.services = {
      # Disable smartcard service (no smartcard hardware)
      "org.gnome.SettingsDaemon.Smartcard".enable = lib.mkForce false;

      # Disable Wacom service (no Wacom tablet - can be re-enabled if needed)
      "org.gnome.SettingsDaemon.Wacom".enable = lib.mkForce false;

      # Disable sharing service (personal laptop, no network sharing)
      "org.gnome.SettingsDaemon.Sharing".enable = lib.mkForce false;
    };

    # XDG Portal consolidation - use only GNOME portal (removes redundancy)
    # Override flatpak module's portal configuration for GNOME desktop
    xdg.portal = {
      enable = true;
      extraPortals = lib.mkForce (with pkgs; [ xdg-desktop-portal-gnome ]);
      config.common.default = lib.mkForce "gnome";
    };
  }; # End of config let block
}
