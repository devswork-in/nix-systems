{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.hypridle = {
    enable = lib.mkEnableOption "Hypridle daemon";
  };

  config = lib.mkIf config.wayland.hypridle.enable {
    # Add hypridle package
    home-manager.users."${userConfig.user.name}" = {
      home.packages = [ pkgs.hypridle ];

      # Configure hypridle via xdg config file
      xdg.configFile."hypridle.conf".source = ./hypridle.conf;

      # Systemd service to start hypridle
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
  };
}
