{ config, lib, pkgs, ... }:

{
  # Configure session manager for Niri
  sessionManager = {
    enable = true;
    autoStart = true;
    sessionType = "wayland";
    sessionCommand = "${pkgs.writeShellScript "start-niri" ''
      # Define variables to import into systemd user session
      VARS="PATH XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP DESKTOP_SESSION DISPLAY WAYLAND_DISPLAY NIRI_SOCKET"

      # Only import variables that are actually set (silences "not set" warnings)
      IMPORT_LIST=""
      for var in $VARS; do
          if [ -n "$(eval echo \$"$var")" ]; then
              IMPORT_LIST="$IMPORT_LIST $var"
          fi
      done

      if [ -n "$IMPORT_LIST" ]; then
          systemctl --user import-environment $IMPORT_LIST
      fi

      # Sync with DBus (only if variables exist)
      if hash dbus-update-activation-environment 2>/dev/null; then
          dbus-update-activation-environment --systemd $IMPORT_LIST
      fi

      # Start niri and wait for it to terminate
      systemctl --user --wait start niri.service

      # Cleanup session on exit
      systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target
    ''}";
  };
}
