{ userConfig, pkgs, ... }:

let
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  services.nginx.virtualHosts = {
    "pg.${userConfig.user.domain}" = {
      inherit (httpsSettings) enableACME forceSSL;
      root = "${userConfig.paths.base}/pg.${userConfig.user.domain}";
      locations = {
        "/" = {
          extraConfig = ''
            try_files $uri $uri/ /index.html;
          '';
        };
      };
    };
  };

  systemd.services.playgrounds-landing-setup = {
    description = "Setup playgrounds landing page";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      mkdir -p ${userConfig.paths.base}/pg.${userConfig.user.domain}
      cp ${pkgs.writeText "index.html" (builtins.readFile ./playgrounds-index.html)} ${userConfig.paths.base}/pg.${userConfig.user.domain}/index.html
    '';
  };
}
