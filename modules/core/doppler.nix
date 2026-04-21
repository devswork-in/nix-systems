{ config, lib, pkgs, userConfig, ... }:

{
  environment.systemPackages = [ pkgs.doppler ];

  # User systemd service to sync secrets from Doppler
  systemd.user.services.doppler-secrets = {
    description = "Fetch secrets from Doppler";
    
    serviceConfig = {
      Type = "oneshot";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    
    script = ''
      set -euo pipefail
      mkdir -p "$HOME/.config/env"
      ${pkgs.doppler}/bin/doppler secrets download --project nix-systems --config prod --no-file --format env \
        | ${pkgs.gnused}/bin/sed 's/^/export /' > "$HOME/.config/env/doppler.sh"

      # Fail visibly if output is empty (auth failure or empty project)
      if [ ! -s "$HOME/.config/env/doppler.sh" ]; then
        echo "ERROR: doppler secrets download produced empty output" >&2
        exit 1
      fi
    '';
  };

  # Timer to refresh secrets every 5 minutes
  systemd.user.timers.doppler-secrets = {
    description = "Refresh Doppler secrets periodically";
    wantedBy = [ "timers.target" ];
    
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "doppler-secrets.service";
    };
  };
}
