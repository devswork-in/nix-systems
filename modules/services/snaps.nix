{ lib, config, ... }:

{
  config = {
    services.snap.enable = lib.mkDefault true;

    # Only configure snapd if enabled
    systemd.services.snapd.wantedBy = lib.mkIf config.services.snap.enable (lib.mkForce [ ]);
    systemd.sockets.snapd.wantedBy = lib.mkIf config.services.snap.enable (lib.mkForce [ ]);

    systemd.timers.snapd-delayed = lib.mkIf config.services.snap.enable {
      wantedBy = [ "graphical.target" ];
      timerConfig = {
        OnActiveSec = "2m";
        Unit = "snapd.service";
      };
    };
  };
}
