{ config, lib, pkgs, userConfig, ... }:
{
  services.llm-gateway = {
    enable    = true;
    apiKeyFile = "/var/lib/llm-gateway/api-key";
    port      = 10204;
  };

  # One service handles both scheduled and manual refreshes; systemd serializes starts.
  systemd.services.gateway-model-refresh = {
    description = "Refresh the OpenCode CLI free-model catalog";
    requires = [ "llm-gateway-hub.service" ];
    after = [ "llm-gateway-hub.service" ];
    environment = {
      HOME = "/var/lib/${config.services.llm-gateway.stateDir}";
      OPENCODEX_HOME = "/var/lib/${config.services.llm-gateway.stateDir}/ocx";
      HUB_PORT = toString config.services.llm-gateway.hubPort;
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "llm-gateway";
      WorkingDirectory = "/var/lib/${config.services.llm-gateway.stateDir}";
      ExecStart = "${pkgs.python3}/bin/python3 ${./refresh-models.py}";
      TimeoutStartSec = "3min";
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/${config.services.llm-gateway.stateDir}" ];
    };
  };
  systemd.timers.gateway-model-refresh = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "0/12:00";
      RandomizedDelaySec = "30min";
      Persistent = true;
    };
  };

  # The pinned Headroom package lacks h2; use HTTP/1.1 until it includes it.
  systemd.services.llm-gateway-headroom.environment.HEADROOM_HTTP2 = "false";

  # ocx skips its token check on a loopback bind, and headroom relays remote
  # traffic to the hub, so refuse to start rather than run unauthenticated.
  systemd.services.llm-gateway-hub.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "llm-gateway-require-auth" ''
      f="$OPENCODEX_HOME/config.json"
      [ -f "$f" ] || exit 0
      host="$(${pkgs.jq}/bin/jq -r '.hostname // ""' "$f")"
      case "$host" in
        ""|localhost|127.*|::1|"[::1]")
          echo "refusing to start: hostname '$host' in $f disables API auth" >&2
          exit 1 ;;
      esac
    '')
  ];

  # Keep the hub non-loopback so ocx enforces its token: headroom relays public
  # traffic to it. Drop non-local traffic in raw, before tailscale's ts-input accepts it.
  networking.firewall = let
    hubRule = "PREROUTING -p tcp --dport ${toString config.services.llm-gateway.hubPort} ! -i lo -j DROP";
  in {
    extraCommands = ''
      iptables -t raw -I ${hubRule}
      ip6tables -t raw -I ${hubRule}
    '';
    extraStopCommands = ''
      iptables -t raw -D ${hubRule} || true
      ip6tables -t raw -D ${hubRule} || true
    '';
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
