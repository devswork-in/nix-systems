{ pkgs, inputs, userConfig, ... }:

{
  imports = [
    # Import server profile (provides common server configuration)
    ../../profiles/server.nix
    
    # System-specific modules
    ../server/hardware-configuration.nix
    
    # Addon modules
    ../../modules/services/website
  ];

  # System-specific configuration
  networking.hostName = "phoenix";

  environment.systemPackages = with pkgs; [
    pnpm
  ];

  # Nginx Reverse Proxy for OpenClaw (Pretty Domain)
  # Nginx Reverse Proxy for OpenClaw (Pretty Domain)
  services.nginx.virtualHosts."bots.${userConfig.user.domain}" = {
    enableACME = true;
    forceSSL = true;
    
    # Using OpenClaw as the root site fixes the WebSocket $(wss://bots.devswork.in/)
    # which expects to be at the root path.
    locations."/" = {
      proxyPass = "http://127.0.0.1:18789/";
      proxyWebsockets = true;
      extraConfig = ''
        allow 100.64.0.0/10;
        allow 127.0.0.1;
        allow ::1;
        deny all;
        
        # Persistent WebSockets
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
      '';
    };

    locations."/openclaw/" = {
      proxyPass = "http://127.0.0.1:18789/";
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

  # Internal DNS for Tailscale Split DNS
  # This makes the "Custom Nameserver" in Tailscale console actually work.
  services.coredns = {
    enable = true;
    config = ''
      bots.${userConfig.user.domain} {
        hosts {
          100.72.57.14 bots.${userConfig.user.domain}
          fallthrough
        }
        log
        errors
      }
    '';
  };

  # Open DNS ports for Tailscale devices to query Phoenix
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
