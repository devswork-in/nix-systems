{ userConfig, ... }:

let
  jellyfin = userConfig.services.jellyfin;
  httpsSettings = {
    enableACME = userConfig.services.website.https;
    forceSSL = userConfig.services.website.https;
  };
in
{
  services = {
    nginx.virtualHosts."${jellyfin.host}" = {
      http2 = true; # http2 can more performant for streaming: https://blog.cloudflare.com/introducing-http2/
      inherit (httpsSettings) enableACME forceSSL;
      locations."/".proxyPass = "http://localhost:" + builtins.toString jellyfin.port;
    };
    jellyfin = {
      enable = true;
      user = jellyfin.user;
    };
  };
}
