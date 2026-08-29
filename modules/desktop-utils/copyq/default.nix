{ config, lib, pkgs, userConfig, ... }:

let cfg = config.services.copyq;
in {
  options.services.copyq = {
    enable = lib.mkEnableOption "CopyQ clipboard manager";
    keybinding = lib.mkOption {
      type = lib.types.str;
      default = "<Super>c";
      description = "Global keybinding to show CopyQ";
    };
    maxItems = lib.mkOption {
      type = lib.types.int;
      default = 200;
      description = "Maximum number of items in clipboard history";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.copyq ];
    systemd.tmpfiles.rules = [
      "L+ /home/${userConfig.user.name}/.config/copyq/copyq.conf - - - - ${./copyq.ini}"
    ];
    systemd.user.services.copyq = {
      description = "CopyQ clipboard manager";
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.copyq}/bin/copyq";
        Restart = "on-failure";
      };
    };
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18/"
        ];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18" = {
          binding = cfg.keybinding;
          command = "${pkgs.copyq}/bin/copyq toggle";
          name = "CopyQ Clipboard Manager";
        };
      };
    }];
  };
}
