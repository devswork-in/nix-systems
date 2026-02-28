{ userConfig, pkgs, pkgs-unstable, ... }:

let
  bots = userConfig.services.bots;
  domain = bots.host;
  endpoint = bots.picoclaw.endpoint;
  port = bots.picoclaw.port;

  picoclaw = pkgs-unstable.buildGoModule rec {
    pname = "picoclaw";
    version = "0.1.2";

    src = pkgs.fetchFromGitHub {
      owner = "sipeed";
      repo = "picoclaw";
      rev = "v${version}";
      hash = "sha256-2q/BQmZaSh88kwquiQlWGS36MVFWWdUzsMxGp4cAMiE=";
    };

    vendorHash = "sha256-3kDU3pbcz+2cd36/bcbdU/IXTAeJosBZ+syUQqO2bls=";

    # 1. Relax Go version (1.25.5 is compatible with 1.25.7)
    # 2. Copy workspace dir for go:embed (normally done by go:generate)
    postPatch = ''
      substituteInPlace go.mod --replace-fail "go 1.25.7" "go 1.25.5"
      cp -r workspace cmd/picoclaw/workspace
    '';

    subPackages = [ "cmd/picoclaw" ];

    meta = {
      description = "Ultra-efficient AI assistant in Go";
      homepage = "https://github.com/sipeed/picoclaw";
    };
  };

  workspaceDir = "/var/lib/picoclaw/workspace";
  configDir = "/var/lib/picoclaw/.picoclaw";
  configFile = "${configDir}/config.json";
in {
  # Systemd service for PicoClaw
  systemd.services.picoclaw = {
    description = "PicoClaw AI Assistant Gateway";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${picoclaw}/bin/picoclaw gateway";
      # Auto-deploy template config if missing (+ prefix = runs as root)
      ExecStartPre = [
        "+${pkgs.bash}/bin/bash -c 'if [ ! -f ${configFile} ]; then mkdir -p ${configDir} && cp ${pkgs.writeText "picoclaw-default-config.json" (builtins.toJSON {
          agents.defaults.model = "gpt-4o";
          providers = {
            openai = {
              api_key = "sk-placeholder-replace-with-real-key";
            };
          };
          gateway = {
            host = "127.0.0.1";
            port = port;
          };
        })} ${configFile} && chmod 640 ${configFile} && chown -R picoclaw:picoclaw /var/lib/picoclaw; fi'"
      ];
      WorkingDirectory = workspaceDir;
      User = "picoclaw";
      Group = "picoclaw";
      Restart = "on-failure";
      RestartSec = 5;

      # Hardening
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ workspaceDir configDir ];
      NoNewPrivileges = true;
      PrivateTmp = true;
    };

    environment = {
      HOME = "/var/lib/picoclaw";
      PICOCLAW_GATEWAY_PORT = toString port;
      PICOCLAW_GATEWAY_HOST = "127.0.0.1";
      PICOCLAW_AGENTS_DEFAULTS_MODEL = "gpt-4o";
    };
  };

  # Directories
  systemd.tmpfiles.rules = [
    "d ${workspaceDir} 0750 picoclaw picoclaw -"
    "d ${configDir} 0700 picoclaw picoclaw -"
  ];

  # System user
  users.users.picoclaw = {
    isSystemUser = true;
    group = "picoclaw";
    home = "/var/lib/picoclaw";
    createHome = true;
  };
  users.groups.picoclaw = {};

  # Nginx proxy location on the shared bots domain
  services.nginx.virtualHosts."${domain}".locations."${endpoint}" = {
    proxyPass = "http://127.0.0.1:${toString port}/";
    proxyWebsockets = true;
    extraConfig = ''
      allow 100.64.0.0/10;
      allow fd7a:115c:a1e0::/48;
      allow 127.0.0.1;
      allow ::1;
      deny all;

      proxy_read_timeout 86400s;
      proxy_send_timeout 86400s;
    '';
  };
}
