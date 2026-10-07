# Walker launcher module - using official walker flake NixOS module
# Requires: walker + elephant flake inputs in flake.nix
{ inputs, pkgs, ... }:

{
  disabledModules = [ "services/misc/elephant.nix" ]; # Walker still imports its own Elephant module.
  imports = [ inputs.walker.nixosModules.default ];




  programs.walker = {
    enable = true;
    # nixpkgs builds are in cache.nixos.org; the flake's own builds compile locally.
    package = pkgs.walker;
    # User config and themes are managed by nix-repo-sync.
    config = {};

    elephant = {
      package = pkgs.elephant;
      providers = [
        "desktopapplications"
        "files"
        "clipboard"
        "calc"
        "symbols"
        "websearch"
        "runner"
        "windows"
        "todo"
        "bookmarks"
        "niriactions"
      ];
    };
  };
}
