{ config, lib, pkgs, userConfig, ... }:

let
  # Detect session type based on available compositors/WMs
  # We use lib.attrByPath to safely check options that might not be defined
  isWayland = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "wayland"
    || (lib.attrByPath ["programs" "niri" "enable"] false config)
    || (lib.attrByPath ["programs" "hyprland" "enable"] false config)
    || (lib.attrByPath ["programs" "sway" "enable"] false config);

  isX11 = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "x11"
    || (lib.attrByPath ["services" "xserver" "windowManager" "dwm" "enable"] false config)
    || (lib.attrByPath ["services" "xserver" "windowManager" "i3" "enable"] false config)
    || (lib.attrByPath ["services" "xserver" "desktopManager" "gnome" "enable"] false config);

  # Common nightlight settings
  latitude = "12.9";
  longitude = "77.5";
  latitudeNum = 12.9719;
  longitudeNum = 77.5937;
  dayTemp = 5500;
  nightTemp = 4000;
in
{
  options.nightlight = {
    enable = lib.mkEnableOption "Nightlight (blue light filter)";
  };

  config = lib.mkIf config.nightlight.enable {
    home-manager.users."${userConfig.user.name}" = { ... }: {
      # Backend for Wayland (Niri, Hyprland, Sway, etc.)
      services.wlsunset = lib.mkIf isWayland {
        enable = true;
        latitude = latitude;
        longitude = longitude;
        temperature = {
          day = dayTemp;
          night = nightTemp;
        };
      };

      # Backend for X11 (DWM, GNOME, etc.)
      services.gammastep = lib.mkIf isX11 {
        enable = true;
        tray = false; # Disable tray indicator - we use our own toggle
        provider = "manual";
        latitude = latitudeNum;
        longitude = longitudeNum;
        temperature = {
          day = dayTemp;
          night = nightTemp + 300; # Slightly warmer for X11
        };
      };

      # Prevent auto-start via systemd - controlled by toggle script
      systemd.user.services = lib.mkMerge [
        (lib.mkIf isWayland {
          wlsunset.Install.WantedBy = lib.mkForce [ ];
        })
        (lib.mkIf isX11 {
          gammastep.Install.WantedBy = lib.mkForce [ ];
          gammastep-indicator.Install.WantedBy = lib.mkForce [ ];
        })
      ];
    };
  };
}
