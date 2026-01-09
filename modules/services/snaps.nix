{ lib, ... }:

{
  services.snap.enable = true;

  # Prevent boot start
  systemd.services.snapd.wantedBy = lib.mkForce [ ];

  # Delay socket activation too (optional but recommended for pure silence)
  systemd.sockets.snapd.wantedBy = lib.mkForce [ ];

  # Delayed start timer
  systemd.timers.snapd-delayed = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      Unit = "snapd.service";
    };
  };
}
