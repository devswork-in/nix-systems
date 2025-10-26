{ pkgs, ... }:

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

  # Configure systemd user service to automatically restart after failure
  systemd.user.services.fusuma = {
    Service = {
      Restart = "always";
      RestartSec = 5;
    };
  };
}
