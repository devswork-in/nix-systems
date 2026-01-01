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

    # Shell-agnostic auto-start on TTY1
    environment.loginShellInit = lib.mkIf config.sessionManager.autoStart ''
      # Auto-start session on TTY1 only
      if [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
        # Check if session is already running
        if ! systemctl --user is-active --quiet niri.service 2>/dev/null; then
          # Start session asynchronously (non-blocking)
          (${config.sessionManager.sessionCommand}) &
          disown
        fi
      fi
    '';

    # Manual start command
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "start-session" ''
        ${config.sessionManager.sessionCommand}
      '')
    ];
  };
}
