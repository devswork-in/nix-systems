{ userConfig, ... }:

let
  leetcode = userConfig.services.leetcode;
  httpsSettings = import ./https-settings.nix { inherit userConfig; };
in
{
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers.leetcode = {
        image = "creator54/leetcode";
        autoStart = true;
        ports = [ "${leetcode.port}:3001" ];
      };
    };
  };

  services.nginx.virtualHosts = {
    "${leetcode.host}" = {
      inherit (httpsSettings) enableACME forceSSL;
      locations."/leetcode" = {
        proxyPass = "http://localhost:${leetcode.port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Prefix /leetcode;
        '';
      };
      locations."/api" = {
        proxyPass = "http://localhost:${leetcode.port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
