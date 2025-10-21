# Complete desktop configuration
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
        ../../essential/packages/common
        ../../essential/packages/desktop
      ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "${stateVersion}";
      };
    };

    backupFileExtension = "bkp";
  };
}