{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.app-usage-tracker;
in {
  options.services.app-usage-tracker = {
    enable = mkEnableOption "app usage tracker via fatrace";

    logPath = mkOption {
      type = types.str;
      default = "/var/log/app-usage.log";
      description = "Path to the log file";
    };

    maxLogSizeMB = mkOption {
      type = types.int;
      default = 50;
      description = "Maximum log file size in MB before rotation";
    };

    retentionDays = mkOption {
      type = types.int;
      default = 7;
      description = "Days to keep historical logs";
    };
  };

  config = mkIf cfg.enable {
    # fatrace logs all file access events system-wide
    environment.systemPackages = with pkgs; [ fatrace ];

    # Main fatrace service - runs at boot, logs all file accesses
    systemd.services.fatrace = {
      description = "File Access Tracker - logs app binary usage for performance optimization";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "fatrace-wrapper" ''
          exec ${pkgs.fatrace}/bin/fatrace \
            --output "${cfg.logPath}" \
            --timestamp \
            --filter "C" \
            2>/dev/null
        '';
        Restart = "on-failure";
        RestartSec = "5s";
        # fatrace needs CAP_SYS_ADMIN for fanotify
        CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
        AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
        # Don't kill on reload
        KillMode = "mixed";
      };
    };

    # Log rotation for the fatrace log
    systemd.services.rotate-app-usage-log = {
      description = "Rotate app usage log file";
      wantedBy = [ "timers.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "rotate-app-log" ''
          LOG="${cfg.logPath}"
          ARCHIVE_DIR="/var/log/app-usage-archive"
          mkdir -p "$ARCHIVE_DIR"

          if [ -f "$LOG" ] && [ -s "$LOG" ]; then
            TIMESTAMP=$(date +%Y%m%d)
            mv "$LOG" "$ARCHIVE_DIR/app-usage-$TIMESTAMP.log"
            # Kill fatrace so it reopens the file
            systemctl restart fatrace.service
          fi

          # Clean up old archives
          find "$ARCHIVE_DIR" -name "app-usage-*.log" -mtime +${toString cfg.retentionDays} -delete
        '';
      };
    };

    # Daily timer for log rotation
    systemd.timers.rotate-app-usage-log = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "rotate-app-usage-log.service";
      };
    };

    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "d /var/log/app-usage-archive 0755 root root -"
      "d ${dirOf cfg.logPath} 0755 root root -"
    ];
  };
}
