{ pkgs, ... }:

let
  # Session file: one hidden window that stays alive to keep the daemon running
  kittyDaemonSession = pkgs.writeText "kitty-daemon-session.kitty" ''
    # Daemon session - hidden window keeps the single-instance daemon alive
    launch sh -c "sleep infinity"
  '';
in {
  systemd.user.services.kitty-daemon = {
    Unit = {
      Description = "Kitty terminal daemon (single-instance)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.kitty}/bin/kitty --single-instance --listen-on unix:/tmp/kitty-socket --session ${kittyDaemonSession} --start-as=hidden";
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = 5;
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
