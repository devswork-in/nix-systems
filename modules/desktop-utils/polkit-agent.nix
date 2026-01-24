{ pkgs, ... }:

{
  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "Pantheon Polkit Authentication Agent";
      Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart =
        "${pkgs.pantheon.pantheon-agent-polkit}/libexec/policykit-1-pantheon/io.elementary.desktop.agent-polkit";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
