{ pkgs, ... }:

{
  services.fusuma = {
    enable = true;
    settings = {
      threshold = {
        swipe = 0.1;
      };
      interval = {
        swipe = 0.7;
      };
      swipe = {
        # allow going back/forward in browsers
        "3" = {
          right = {
            command = "xdotool key alt+Left";
          };
          left = {
            command = "xdotool key alt+Right";
          };
        };
        "4" = {
          right = {
            # GNOME: Switch to left workspace
            command = "xdotool key ctrl+Left";
          };
          left = {
            # GNOME: Switch to right workspace
            command = "xdotool key ctrl+Right";
          };
        };
      };
    };
  };
}
