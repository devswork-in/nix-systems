{ config, lib, pkgs, userConfig, ... }:

with lib;

let
  cfg = config.services.copyq;
  user = userConfig.user.name;
in
{
  options.services.copyq = {
    enable = mkEnableOption "CopyQ clipboard manager";

    keybinding = mkOption {
      type = types.str;
      default = "<Super>c";
      description = "Global keybinding to show CopyQ";
    };

    maxItems = mkOption {
      type = types.int;
      default = 200;
      description = "Maximum number of items in clipboard history";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = [ pkgs.copyq ];

      # Deploy CopyQ configuration file
      xdg.configFile."copyq/copyq.conf" = {
        source = ./copyq.ini;
        onChange = ''
          ${pkgs.systemd}/bin/systemctl --user restart copyq.service
        '';
      };

      # Configure systemd user service for autostart
      systemd.user.services.copyq = {
        Unit = {
          Description = "CopyQ clipboard manager";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.copyq}/bin/copyq";
          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      # Configure GNOME keybinding
      dconf.settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18" = {
          binding = cfg.keybinding;
          command = "${pkgs.copyq}/bin/copyq toggle";
          name = "CopyQ Clipboard Manager";
        };
      };
    };
  };
}
