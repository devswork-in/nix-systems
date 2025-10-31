{ userConfig, ... }:

let
  httpsSettings = {
    enableACME = userConfig.services.website.https;
    forceSSL = userConfig.services.website.https;
  };
in
{
  imports = [
    ./repo-sync-service.nix
  ];
  networking.firewall.allowedTCPPorts =
    if userConfig.services.website.https then
      [
        80
        443
      ]
    else
      [ 80 ];

  services = {
    nginx = {
      enable = true;
      enableReload = true;
      statusPage = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      virtualHosts = {
        "${userConfig.user.domain}" = {
          inherit (httpsSettings) enableACME forceSSL;
          root = "${userConfig.paths.base}/${userConfig.user.domain}";
          locations = {
            "/".extraConfig = ''
              rewrite ^/(.*)$ https://blog.${userConfig.user.domain} redirect;
            '';
            "/blog".extraConfig = ''
              rewrite ^/(.*)$ https://blog.${userConfig.user.domain} redirect;
            '';
            "/blog/".extraConfig = ''
              rewrite ^/blog/(.*)$ https://blog.${userConfig.user.domain}/$1 redirect;
            '';
          };
        };
        "blog.${userConfig.user.domain}" = {
          inherit (httpsSettings) enableACME forceSSL;
          root = "${userConfig.paths.base}/blog.${userConfig.user.domain}/_site";
        };
        "labs.${userConfig.user.domain}" = {
          inherit (httpsSettings) enableACME forceSSL;
          locations = {
            "/".proxyPass = "http://localhost:8000";
          };
        };
      };
    };
  };

  security.acme =
    if userConfig.services.website.https then
      {
        acceptTerms = true;
        certs = {
          "${userConfig.user.domain}" = {
            webroot = "/var/lib/acme/acme-challenge";
            domain = "${userConfig.user.domain}";
          };
        };
        defaults.email = "${userConfig.user.email}";
      }
    else
      { };

  systemd.services.nginx.serviceConfig.ProtectHome = "read-only";
}
