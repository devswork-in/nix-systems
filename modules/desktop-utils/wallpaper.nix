{ config, lib, pkgs, userConfig, ... }:

let
  # Detect session type (Same logic as nightlight.nix)
  isWayland = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "wayland"
    || (lib.attrByPath ["programs" "niri" "enable"] false config)
    || (lib.attrByPath ["programs" "hyprland" "enable"] false config)
    || (lib.attrByPath ["programs" "sway" "enable"] false config);

  isX11 = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "x11"
    || (lib.attrByPath ["services" "xserver" "windowManager" "dwm" "enable"] false config)
    || (lib.attrByPath ["services" "xserver" "windowManager" "i3" "enable"] false config)
    || (lib.attrByPath ["services" "xserver" "desktopManager" "gnome" "enable"] false config);

  # Default wallpaper path
  defaultWallpaper = "${config.users.users.${userConfig.user.name}.home}/.current_wallpaper";
in
{
  options.desktop.wallpaper = {
    enable = lib.mkEnableOption "Desktop Wallpaper Manager";
    path = lib.mkOption {
      type = lib.types.str;
      default = defaultWallpaper;
      description = "Path to the wallpaper image";
    };
  };

  config = lib.mkIf config.desktop.wallpaper.enable {
    home-manager.users."${userConfig.user.name}" = { ... }: {
      home.packages = with pkgs; [
        (lib.mkIf isWayland swaybg)
        (lib.mkIf isX11 feh)
      ];

      # Wayland: swaybg service
      systemd.user.services.swaybg = lib.mkIf isWayland {
        Unit = {
          Description = "Wayland Wallpaper Service (swaybg)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${config.desktop.wallpaper.path}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      # X11: feh service
      # Note: For DWM/startx, systemd user services might start too early or late depending on integration.
      # But 'graphical-session.target' is usually reached. 
      # Alternatively, we can just install the package and let xinitrc call a wrapper.
      systemd.user.services.wallpaper-x11 = lib.mkIf isX11 {
        Unit = {
          Description = "X11 Wallpaper Service (feh)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${config.desktop.wallpaper.path}";
          RemainAfterExit = true;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
