# Complete server configuration
{ ... }:
let
  config = (import ../../config.nix { });
  user = config.userName;
  stateVersion = config.nixosReleaseVersion;
in
{
  home-manager = {
    users."${user}" = { ... }: {
      imports = [
        ../packages/common
        ../packages/server
        ../configs/server/environment.nix
      ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "${stateVersion}";
      };
    };

    backupFileExtension = null;
  };
}
