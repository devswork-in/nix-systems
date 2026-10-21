{ config, lib, userConfig, ... }:
{
  services.llm-gateway = {
    enable    = true;
    apiKeyFile = "/var/lib/llm-gateway/api-key";
    port      = 10204;
  };

  services.nginx.virtualHosts = {
    # Disable unused vhosts that come from shared website modules.
    "labs.${userConfig.user.domain}" = lib.mkForce { };
    "pg.${userConfig.user.domain}"   = lib.mkForce { };

    "llm.${userConfig.user.domain}" = {
      enableACME = userConfig.services.website.https;
      forceSSL   = userConfig.services.website.https;
      locations."/" = {
        proxyPass      = "http://127.0.0.1:${toString config.services.llm-gateway.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 600s;
          client_max_body_size 32m;
        '';
      };
    };
  };
}
