{ pkgs, lib, config, ... }:

let
  # Script to ensure fusuma has proper access to input devices
  fusumaSetup = pkgs.writeShellScript "fusuma-setup" ''
    # Wait for GNOME Shell to fully initialize
    sleep 3
    
    # Ensure input group permissions are correct
    for device in /dev/input/event*; do
      if [ -e "$device" ]; then
        chmod 660 "$device" 2>/dev/null || true
        chgrp input "$device" 2>/dev/null || true
      fi
    done
    
    # Log device access
    echo "Fusuma setup completed at $(date)" >> /tmp/fusuma-setup.log
  '';
  
  # Watchdog script to monitor and restart fusuma
  fusumaWatchdog = pkgs.writeShellScript "fusuma-watchdog" ''
    PATH=${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.systemd}/bin:${pkgs.gnugrep}/bin:$PATH
    
    # Wait for fusuma to start initially
    sleep 15
    
    LAST_GESTURE_COUNT=0
    NO_GESTURE_CYCLES=0
    
    while true; do
      sleep 45
      
      # Check if fusuma is running
      if ! pgrep -f "\.fusuma-wrapped" > /dev/null; then
        echo "[$(date)] Fusuma not running, restarting..."
        systemctl --user restart fusuma
        NO_GESTURE_CYCLES=0
        sleep 5
        continue
      fi
      
      # Check for X connection errors in recent logs
      X_ERRORS=$(journalctl --user -u fusuma --since "60 seconds ago" 2>/dev/null | grep -c "X connection.*broken\|unable to open display" 2>/dev/null || echo "0")
      X_ERRORS=$(echo "$X_ERRORS" | tr -d '[:space:]')
      
      if [ "''${X_ERRORS:-0}" -gt 0 ] 2>/dev/null; then
        echo "[$(date)] X connection errors detected, restarting fusuma..."
        systemctl --user restart fusuma
        NO_GESTURE_CYCLES=0
        sleep 5
        continue
      fi
      
      # Count gesture events in the last 60 seconds
      CURRENT_GESTURE_COUNT=$(journalctl --user -u fusuma --since "60 seconds ago" 2>/dev/null | grep -c "command=" 2>/dev/null || echo "0")
      CURRENT_GESTURE_COUNT=$(echo "$CURRENT_GESTURE_COUNT" | tr -d '[:space:]')
      
      # If no gestures detected, increment counter
      if [ "''${CURRENT_GESTURE_COUNT:-0}" -eq 0 ] 2>/dev/null; then
        NO_GESTURE_CYCLES=$((NO_GESTURE_CYCLES + 1))
        echo "[$(date)] No gestures detected (cycle $NO_GESTURE_CYCLES)"
        
        # If no gestures for 2 consecutive checks (90 seconds), restart
        if [ "$NO_GESTURE_CYCLES" -ge 2 ]; then
          echo "[$(date)] No gestures for too long, restarting fusuma..."
          systemctl --user restart fusuma
          NO_GESTURE_CYCLES=0
          sleep 5
        fi
      else
        # Gestures detected, reset counter
        NO_GESTURE_CYCLES=0
      fi
      
      LAST_GESTURE_COUNT=$CURRENT_GESTURE_COUNT
    done
  '';
in
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
  # and ensure it starts after GNOME Shell to override its gesture handling
  systemd.user.services.fusuma = {
    Unit = {
      After = [ "graphical-session.target" ];
      # Override PartOf to prevent fusuma from being stopped when graphical-session restarts
      # This prevents fusuma from being stopped during time sync events
      PartOf = lib.mkForce [ ];
    };
    Service = {
      Restart = "always";
      RestartSec = 3;
      # Run setup script before starting fusuma
      ExecStartPre = toString fusumaSetup;
      # Ensure xdotool is in PATH for fusuma to execute gesture commands
      Environment = lib.mkForce "PATH=${pkgs.xdotool}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin:${config.home.profileDirectory}/bin";
      # Prevent systemd from stopping fusuma during time changes
      TimeoutStopSec = 5;
    };
  };
  
  # Restart fusuma after home-manager activation to ensure it has the correct environment
  home.activation.restartFusuma = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ${pkgs.systemd}/bin/systemctl --user is-active fusuma.service >/dev/null 2>&1; then
      $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user restart fusuma.service || true
      echo "Restarted fusuma service"
    fi
  '';
  
  # Create a systemd service to monitor and restart fusuma if it stops or gestures stop working
  systemd.user.services.fusuma-watchdog = {
    Unit = {
      Description = "Watchdog to restart fusuma if gestures stop working";
      # Remove After dependency to avoid ordering cycle
      Wants = [ "fusuma.service" ];
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 15;
      ExecStart = toString fusumaWatchdog;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
