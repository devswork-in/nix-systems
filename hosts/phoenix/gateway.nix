{ config, lib, userConfig, ... }:
{
  # gw: single Rust binary; accounts live in /var/lib/llm-gateway.
  services.llm-gateway = {
    enable     = true;
    apiKeyFile = "/var/lib/llm-gateway/api-key";
    port       = 10204;
  };

  services.nginx.virtualHosts = {
    # Disable unused vhosts that come from shared website modules.
    "labs.${userConfig.user.domain}" = lib.mkForce { };
    "pg.${userConfig.user.domain}"   = lib.mkForce { };

    "llm.${userConfig.user.domain}" = {
      enableACME = userConfig.services.website.https;
      forceSSL   = userConfig.services.website.https;
      locations."/" = {
        proxyPass       = "http://127.0.0.1:${toString config.services.llm-gateway.port}";
        proxyWebsockets = true;
        # Tailnet and local clients only; ACME challenges keep their own public location.
        extraConfig = ''
          allow 127.0.0.1;
          allow ::1;
          allow 100.64.0.0/10;
          allow fd7a:115c:a1e0::/48;
          deny all;
          proxy_buffering off;
          proxy_read_timeout 600s;
          client_max_body_size 32m;
        '';
      };
    };
  };
}
