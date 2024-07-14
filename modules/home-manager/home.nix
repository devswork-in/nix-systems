{ ... }:
let
  config = (import ./../../config.nix {});
  user = config.userName;
  stateVersion = config.nixosReleaseVersion;
in 
{
  home-manager = {
    users."${user}" = { ... }: {
      imports = [
        ./pkgs/general.nix
        ./configs/symlinks.nix
      ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "${stateVersion}";
      };
    };

    # do home-manager switch -b by default
    # ref: https://nix-community.github.io/home-manager/nixos-options.xhtml#nixos-opt-home-manager.backupFileExtension
    # ref: https://discourse.nixos.org/t/way-to-automatically-override-home-manager-collisions/33038
    # ref: https://www.reddit.com/r/NixOS/comments/1d3f15l/homemanager_wants_something_strange/
    backupFileExtension = "bkp";
  };
}
