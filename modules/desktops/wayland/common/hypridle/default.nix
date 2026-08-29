{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.hypridle = {
    enable = lib.mkEnableOption "Hypridle daemon";
  };

  config = lib.mkIf config.wayland.hypridle.enable {
    environment.systemPackages = [ pkgs.hypridle ];
    systemd.tmpfiles.rules = [
      "L+ /home/${userConfig.user.name}/.config/hypridle.conf - - - - ${./hypridle.conf}"
    ];
    systemd.user.services.hypridle = {
        Unit = {
          Description = "Hypridle daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
    };
  };
}
