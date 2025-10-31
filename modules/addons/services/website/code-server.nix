{ userConfig, ... }:

let
  codeServer = userConfig.services.codeServer;
  httpsSettings = {
    enableACME = userConfig.services.website.https;
    forceSSL = userConfig.services.website.https;
  };
in
{
  services = {
    # Gzip and Proxy optimisations needs to be disabled for this to work, also authentication with password always fails
    code-server = {
      enable = true;
      auth = "none";
      port = codeServer.port;
      user = "${codeServer.user}";
    };
    nginx = {
      virtualHosts = {
        "${codeServer.host}" = {
          inherit (httpsSettings) enableACME forceSSL;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection upgrade;
            proxy_set_header Accept-Encoding gzip;
          '';
          locations."/".proxyPass = "http://localhost:" + builtins.toString codeServer.port;
        };
      };
    };
  };
}
