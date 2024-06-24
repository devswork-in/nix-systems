{ ... }:
{
  home-manager.users."creator54" = { ... }: {
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
}
