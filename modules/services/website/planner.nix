{ userConfig, ... }:

let
  pg = userConfig.services.pg;
  planner = pg.planner;
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers.planner = {
        image = "creator54/planner";
        autoStart = true;
        ports = [ "${planner.port}:80" ];
        extraOptions = [ "--pull=always" ];
      };
    };
  };

  services.nginx.virtualHosts = {
    "${pg.host}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/planner" = {
        proxyPass = "http://127.0.0.1:${planner.port}/";
      };
    };
  };
}
