{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.swaync.enable =
    lib.mkEnableOption "SwayNC notification daemon";

  config = lib.mkIf config.wayland.swaync.enable {
    environment.systemPackages = [ pkgs.swaynotificationcenter ];
    systemd.user.services.swaync = {
      description = "Swaync notification daemon";
      documentation = [ "https://github.com/ErikReider/SwayNotificationCenter" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
        ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config ; ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css";
        Restart = "on-failure";
        Environment = [ "GSK_RENDERER=cairo" ];
      };
    };
  };
}
