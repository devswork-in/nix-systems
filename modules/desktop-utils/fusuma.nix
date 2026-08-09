{ pkgs, lib, config, ... }:

{
  services.fusuma = {
    enable = true;
    package = pkgs.fusuma;
    settings = {
      threshold = {
        swipe = 0.1;
      };
      interval = {
        swipe = 0.7;
      };
      swipe = {
        # 3-finger gestures for browser navigation
        "3" = {
          right = {
            command = "xdotool key alt+Left";
          };
          left = {
            command = "xdotool key alt+Right";
          };
        };
        # 4-finger gestures for workspace switching and window operations
        "4" = {
          right = {
            command = "xdotool key ctrl+Left";
          };
          left = {
            command = "xdotool key ctrl+Right";
          };
        };
      };
    };
  };

  # Input permissions are provided by the host udev rule.
  systemd.user.services.fusuma = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = lib.mkForce [ ];
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 3;
      Environment = lib.mkForce "PATH=${pkgs.xdotool}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin:${config.home.profileDirectory}/bin";
      TimeoutStopSec = 5;
    };
  };
}
