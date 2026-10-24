{ config, userConfig, lib, ... }:

let
  services = userConfig.services;
  domain = userConfig.user.domain;
  tsIp = "100.72.57.14"; # Phoenix Tailscale IP

  hosts = [
    (if (services ? openclaw && services.openclaw.enable) then "${tsIp} ${services.openclaw.host}" else "")
    (if (services ? windmill && services.windmill.enable) then "${tsIp} ${services.windmill.host}" else "")
    # Tailnet-only vhost (see hosts/phoenix/gateway.nix): the public record is denied by nginx.
    (if config.services.llm-gateway.enable then "${tsIp} llm.${domain}" else "")
  ];
  
  activeHosts = lib.filter (h: h != "") hosts;
  hostsContent = lib.concatStringsSep "\n    " activeHosts;
in
{
  services.coredns = lib.mkIf (activeHosts != []) {
    enable = true;
    config = ''
      ${domain} {
        hosts {
          ${hostsContent}
          fallthrough
        }
        reload
        log
        errors
      }
    '';
  };
}
