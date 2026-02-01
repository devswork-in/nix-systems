{ userConfig, lib, ... }:

let
  services = userConfig.services;
  domain = userConfig.user.domain;
  tsIp = "100.72.57.14"; # Phoenix Tailscale IP
  
  hosts = [
    (if (services ? openclaw && services.openclaw.enable) then "${tsIp} ${services.openclaw.host}" else "")
    (if (services ? windmill && services.windmill.enable) then "${tsIp} ${services.windmill.host}" else "")
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
  
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
