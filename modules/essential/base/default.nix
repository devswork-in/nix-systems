# Base home-manager configuration for all systems
{ ... }:
let
  config = (import ../../../config.nix { });
  user = config.userName;
  stateVersion = config.nixosReleaseVersion;
in
{
  home-manager = {
    users."${user}" = { ... }: {
      imports = [
        ../packages/common  # Import common packages
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