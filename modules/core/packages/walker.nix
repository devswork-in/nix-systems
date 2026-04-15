# Walker launcher module - using official walker flake NixOS module
# Requires: walker + elephant flake inputs in flake.nix
{ inputs, ... }:

{
  imports = [ inputs.walker.nixosModules.default ];

  programs.walker = {
    enable = true;
  };
}
