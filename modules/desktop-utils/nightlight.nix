{ config, lib, pkgs, ... }:

let
  isWayland = (lib.attrByPath [ "sessionManager" "sessionType" ] "" config) == "wayland"
    || lib.attrByPath [ "programs" "niri" "enable" ] false config
    || lib.attrByPath [ "programs" "hyprland" "enable" ] false config
    || lib.attrByPath [ "programs" "sway" "enable" ] false config;
  isX11 = (lib.attrByPath [ "sessionManager" "sessionType" ] "" config) == "x11"
    || lib.attrByPath [ "services" "xserver" "windowManager" "dwm" "enable" ] false config
    || lib.attrByPath [ "services" "xserver" "windowManager" "i3" "enable" ] false config
    || lib.attrByPath [ "services" "desktopManager" "gnome" "enable" ] false config;
in {
  options.nightlight.enable = lib.mkEnableOption "Nightlight (blue light filter)";
  config = lib.mkIf config.nightlight.enable {
    environment.systemPackages = lib.optionals isWayland [ pkgs.wlsunset ]
      ++ lib.optionals isX11 [ pkgs.gammastep ];
    systemd.user.services = lib.mkMerge [
      (lib.mkIf isWayland {
        wlsunset = {
          description = "Day/night gamma adjustments for Wayland compositors";
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
          serviceConfig.ExecStart = "${pkgs.wlsunset}/bin/wlsunset -L77.5 -T5500 -g1.000000 -l12.9 -t4000";
        };
      })
      (lib.mkIf isX11 {
        gammastep = {
          description = "Day/night gamma adjustments for X11";
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig.ExecStart = "${pkgs.gammastep}/bin/gammastep -l 12.9719:77.5937 -t 5500:4300";
        };
      })
    ];
  };
}
