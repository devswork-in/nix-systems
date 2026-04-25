{ config, lib, pkgs, userConfig, ... }:

{
  # Systemd user service to sync /etc/nixos symlink at login
  home-manager.users."${userConfig.user.name}" = {
    systemd.user.services.nixos-config-sync = {
      Unit = {
        Description = "Sync /etc/nixos to discovered nix-systems repo";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'PATH=\${HOME}/.local/bin:\$PATH nixos-config-sync'";
        StandardOutput = "journal";
        StandardError = "journal";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
