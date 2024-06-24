{ ... }:
{
  home-manager = {
    users."creator54" = { ... }: {
      imports = [
        ./pkgs/general.nix
        ./configs/symlinks.nix
      ];

      home = {
        username = "creator54";
        homeDirectory = "/home/creator54";
        stateVersion = "23.11";
      };
    };

    # do home-manager switch -b by default
    # ref: https://nix-community.github.io/home-manager/nixos-options.xhtml#nixos-opt-home-manager.backupFileExtension
    # ref: https://discourse.nixos.org/t/way-to-automatically-override-home-manager-collisions/33038
    # ref: https://www.reddit.com/r/NixOS/comments/1d3f15l/homemanager_wants_something_strange/
    backupFileExtension = "bkp";
  };
}
