{ pkgs, ... }:

let
  config = (pkgs.formats.yaml { }).generate "fusuma.yml" {
    threshold.swipe = 0.1;
    interval.swipe = 0.7;
    swipe = {
      "3" = {
        right.command = "xdotool key alt+Left";
        left.command = "xdotool key alt+Right";
      };
      "4" = {
        right.command = "xdotool key ctrl+Left";
        left.command = "xdotool key ctrl+Right";
      };
    };
  };
in {
  environment.systemPackages = with pkgs; [ fusuma xdotool ];
  systemd.user.services.fusuma = {
    description = "Fusuma touchpad gestures";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fusuma}/bin/fusuma --config=${config}";
      Environment = "PATH=${pkgs.xdotool}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin";
      Restart = "on-failure";
      RestartSec = 3;
      TimeoutStopSec = 5;
    };
  };
}
