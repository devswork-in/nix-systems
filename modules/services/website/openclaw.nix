{ config, lib, userConfig, ... }:

with lib;

let
  cfg = userConfig.services.openclaw;
  domain = cfg.host;
  port = cfg.port;
in {
  # Nginx Reverse Proxy for OpenClaw (Pretty Domain)
  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    
    # Using OpenClaw as the root site fixes the WebSocket $(wss://bots.devswork.in/)
    # which expects to be at the root path.
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
      proxyWebsockets = true;
      extraConfig = ''
        allow 100.64.0.0/10;
        allow fd7a:115c:a1e0::/48;
        allow 127.0.0.1;
        allow ::1;
        deny all;
        
        # Persistent WebSockets
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
      '';
    };

    locations."/openclaw/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
      proxyWebsockets = true;
      # Enforce Tailscale-only access.
      extraConfig = ''
        allow 100.64.0.0/10;
        allow 127.0.0.1;
        allow ::1;
        deny all;
      '';
    };
  };
}
