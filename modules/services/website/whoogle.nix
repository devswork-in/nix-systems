{ userConfig, lib, ... }:

let
  whoogle = userConfig.services.whoogle;
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers.whoogle-search = {
        image = "benbusby/whoogle-search:1.1.2";
        autoStart = true;
        ports = [ "${whoogle.port}:5000" ];
        environment = {
          WHOOGLE_CONFIG_USE_LETA = "0";
        };
      };
    };
  };

  services.nginx.virtualHosts = {
    "${whoogle.host}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/".proxyPass = "http://localhost:${whoogle.port}";
    };
  };
}
