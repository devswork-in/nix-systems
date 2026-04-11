{ userConfig, ... }:

{
  imports = [
    (if userConfig.services.website.enable then ./website.nix else { })
    (if userConfig.services.whoogle.enable then ./whoogle.nix else { })
    (if userConfig.services.adguard.enable then ./adguard.nix else { })
    (if userConfig.services.plex.enable then ./plex-server.nix else { })
    (if userConfig.services.jellyfin.enable then ./jellyfin.nix else { })
    (if userConfig.services.nextCloud.enable then ./next-cloud.nix else { })
    (if userConfig.services.codeServer.enable then ./code-server.nix else { })

    (if userConfig.services.openclaw.enable then ./openclaw.nix else { })
    (if userConfig.services.windmill.enable then ./windmill.nix else { })
    (if userConfig.services.loomwork.enable then ./loomwork.nix else { })
    (if userConfig.services.pg.leetcode.enable then ./leetcode.nix else { })
    (if userConfig.services.pg.planner.enable then ./planner.nix else { })

    ./playgrounds-landing.nix
    ./tailscale-dns.nix
  ];
}
