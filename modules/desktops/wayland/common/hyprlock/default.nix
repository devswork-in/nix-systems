{ config, lib, pkgs, userConfig, ... }:

{
  options.wayland.hyprlock = {
    enable = lib.mkEnableOption "Hyprlock screen locker";
    autoLock = lib.mkEnableOption "Auto-lock on session start";
  };

  config = lib.mkIf config.wayland.hyprlock.enable {
    # System-level hyprlock for PAM support
    programs.hyprlock.enable = true;

    # Explicitly enable PAM service for hyprlock to avoid "init first step" errors
    security.pam.services.hyprlock = { };

    # Add hyprlock package
    home-manager.users."${userConfig.user.name}".home.packages =
      [ pkgs.hyprlock ];

    # Auto-lock systemd service (Disabled in favor of Niri spawn-at-startup for faster lock)
    # systemd.user.services.hyprlock-autolock =
    #   lib.mkIf config.wayland.hyprlock.autoLock {
    #     description = "Auto-lock screen on session startup";
    #     after = [ "graphical-session.target" ];
    #     partOf = [ "graphical-session.target" ];
    #     wantedBy = [ "graphical-session.target" ];
    #
    #     serviceConfig = {
    #       Type = "simple";
    #       ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
    #       Restart = "no";
    #     };
    #   };
  };
}
