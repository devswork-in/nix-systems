let
  config = (import ./../../config.nix {});
in
{
  imports = [
    (if config.website.enable then ./website.nix else {})
    (if config.website.whoogle.enable then ./add-ons/whoogle.nix else {})
    (if config.website.adguard.enable then ./add-ons/adguard.nix else {})
    (if config.website.plex.enable then ./add-ons/plex-server.nix else {})
    (if config.website.jellyfin.enable then ./add-ons/jellyfin.nix else {})
    (if config.website.nextCloud.enable then ./add-ons/next-cloud.nix else {})
    (if config.website.codeServer.enable then ./add-ons/code-server.nix else {})
  ];
}

