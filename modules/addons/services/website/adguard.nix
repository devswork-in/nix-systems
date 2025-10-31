{ userConfig, ... }:

let
  adguard = userConfig.services.adguard;
in
{
  services = {
    nginx.virtualHosts."${adguard.host}" = {
      forceSSL = userConfig.services.website.https;
      enableACME = userConfig.services.website.https;
      locations."/".proxyPass = "http://localhost:" + builtins.toString adguard.port;
    };
    adguardhome = {
      enable = true;
      port = adguard.port;
    };
  };
}
