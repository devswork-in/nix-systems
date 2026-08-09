{ config, lib, pkgs, userConfig, ... }:

{
  environment.systemPackages = [ pkgs.doppler ];

  # User systemd service to sync secrets from Doppler
  systemd.user.services.doppler-secrets = {
    description = "Fetch secrets from Doppler";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      UMask = "0077";
    };
    
    script = ''
      set -euo pipefail
      env_dir="$HOME/.config/env"
      mkdir -p "$env_dir"
      env_pending=$(mktemp "$env_dir/.doppler.env.XXXXXX")
      shell_pending=$(mktemp "$env_dir/.doppler.sh.XXXXXX")
      trap 'rm -f "$env_pending" "$shell_pending"' EXIT

      ${pkgs.doppler}/bin/doppler secrets download --project nix-systems --config prod --no-file --format env \
        > "$env_pending"
      if [ ! -s "$env_pending" ]; then
        echo "ERROR: doppler secrets download produced empty output" >&2
        exit 1
      fi

      ${pkgs.gnused}/bin/sed 's/^/export /' "$env_pending" > "$shell_pending"
      chmod 0600 "$env_pending" "$shell_pending"
      mv -f "$shell_pending" "$env_dir/doppler.sh"
      mv -f "$env_pending" "$env_dir/doppler.env"
      trap - EXIT
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
