{ config, lib, pkgs, userConfig, flakeRoot, ... }:

{
  environment.systemPackages = [ pkgs.doppler ];

  # User systemd service to sync secrets from Doppler
  systemd.user.services.doppler-secrets = {
    description = "Fetch secrets from Doppler";
    wantedBy = [ "default.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = flakeRoot;
    };
    
    script = ''
      # Create secrets directory
      mkdir -p /run/user/$UID/secrets
      
      # Fetch secrets from Doppler
      ${pkgs.doppler}/bin/doppler secrets download --no-file --format env > /run/user/$UID/secrets/doppler.env
    '';
  };

  # Make Doppler secrets available to user shells
  environment.extraInit = ''
    if [ -f /run/user/$UID/secrets/doppler.env ]; then
      set -a
      source /run/user/$UID/secrets/doppler.env
      set +a
    fi
  '';
}
