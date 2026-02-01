{ config, lib, userConfig, pkgs-unstable, ... }:

with lib;

let
  cfg = userConfig.services.windmill;
  domain = cfg.host;
  port = cfg.port;
in {
  services.windmill = {
    enable = true;
    package = pkgs-unstable.windmill;
    serverPort = port;
    baseUrl = "https://${domain}";
    database.createLocally = true;
  };

  # Nginx Reverse Proxy for Windmill
  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
      proxyWebsockets = true;
      extraConfig = ''
        # Tailscale IPv4 and IPv6 ranges
        allow 100.64.0.0/10;
        allow fd7a:115c:a1e0::/48;
        allow 127.0.0.1;
        allow ::1;
        deny all;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_set_header X-Forwarded-Port 443;

        # Persistent WebSockets
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
      '';
    };
  };
}
