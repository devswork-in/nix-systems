{ userConfig, ... }:

let
  adguard = userConfig.services.adguard;
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  services = {
    nginx.virtualHosts."${adguard.host}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/".proxyPass = "http://localhost:" + builtins.toString adguard.port;
    };
    adguardhome = {
      enable = true;
      port = adguard.port;
    };
  };
}
