# Walker launcher module - using official walker flake NixOS module
# Requires: walker + elephant flake inputs in flake.nix
{ inputs, ... }:

{
  disabledModules = [ "services/misc/elephant.nix" ]; # Walker still imports its own Elephant module.
  imports = [ inputs.walker.nixosModules.default ];




  programs.walker = {
    enable = true;
    # User config and themes are managed by nix-repo-sync.
    config = {};

    elephant = {
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
