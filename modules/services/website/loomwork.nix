{ userConfig, ... }:

let
  loomwork = userConfig.services.loomwork;
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  services.nginx.virtualHosts = {
    "${loomwork.host}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/" = {
        proxyPass = "http://localhost:${toString loomwork.port}";
        proxyWebsockets = true;
      };
    };
    "${loomwork.apiHost}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/" = {
        proxyPass = "http://localhost:${toString loomwork.port}";
        extraConfig = ''
          proxy_read_timeout 120s;
        '';
      };
    };
  };
}
