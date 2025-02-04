let
  config = (import ./../../config.nix { });
in
{
  imports = [
    (if config.website.enable then ./website.nix else { })
    (if config.whoogle.enable then ./add-ons/whoogle.nix else { })
    (if config.adguard.enable then ./add-ons/adguard.nix else { })
    (if config.plex.enable then ./add-ons/plex-server.nix else { })
    (if config.jellyfin.enable then ./add-ons/jellyfin.nix else { })
    (if config.nextCloud.enable then ./add-ons/next-cloud.nix else { })
    (if config.codeServer.enable then ./add-ons/code-server.nix else { })
  ];
}
