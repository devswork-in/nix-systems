{ config, lib, pkgs, userConfig, ... }:

{
  options.sessionManager = {
    enable = lib.mkEnableOption "Auto-login session manager";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically start the session on TTY login";
    };

    sessionCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command to start the session";
      example = "niri-session";
    };

    sessionType = lib.mkOption {
      type = lib.types.enum [ "wayland" "x11" ];
      description = "Session type (wayland or x11)";
      default = "wayland";
    };
  };

  config = lib.mkIf config.sessionManager.enable {
    # TTY1 auto-login
    services.getty.autologinUser = userConfig.user.name;

    # provide a manual start command
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "start-session" ''
        ${config.sessionManager.sessionCommand}
      '')
    ];

  };
}
