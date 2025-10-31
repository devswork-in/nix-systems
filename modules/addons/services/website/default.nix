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
  ];
}
