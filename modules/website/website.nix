let
  config = (import ./../../config.nix {});
  httpsSettings = import ./https-settings.nix;
in
{
  imports = [
    ./repo-sync-service.nix
  ];
  networking.firewall.allowedTCPPorts = if config.website.https then [ 80 443 ] else [ 80 ];

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
        "${config.hostName}" = {
          inherit (httpsSettings) enableACME forceSSL;
          root = "${config.syncRepos.hostSrc.localPath}";
          locations = {
            "/".extraConfig = ''
              rewrite ^/(.*)$ https://blog.${config.hostName} redirect;
            '';
            "/blog".extraConfig = ''
              rewrite ^/(.*)$ https://blog.${config.hostName} redirect;
            '';
            "/blog/".extraConfig = ''
              rewrite ^/blog/(.*)$ https://blog.${config.hostName}/$1 redirect;
            '';
          };
        };
        "blog.${config.hostName}" = {
          inherit (httpsSettings) enableACME forceSSL;
          root = "${config.syncRepos.blogSrc.localPath}/_site";
        };
        "labs.${config.hostName}" = {
          inherit (httpsSettings) enableACME forceSSL;
          locations = {
            "/".proxyPass = "http://localhost:8000";
          };
        };
      };
    };
  };

  security.acme = if config.website.https then {
    acceptTerms = true;
    certs = {
      "${config.hostName}" = {
        webroot = "/var/lib/acme/acme-challenge";
        domain = "${config.hostName}";
      };
    };
    defaults.email = "${config.userEmail}";
  } else {};

  systemd.services.nginx.serviceConfig.ProtectHome = "read-only";
}
