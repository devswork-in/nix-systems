{ ... }:
let
  whoogle = (import ./../../config.nix {}).website.whoogle;
  httpsSettings = import ./../https-settings.nix;
in
{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers.whoogle-search = {
        image = "benbusby/whoogle-search:latest";
        autoStart = true;
        ports = [ "${whoogle.port}:5000" ]; #server localhost : docker localhost
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

