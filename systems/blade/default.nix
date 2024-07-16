{ inputs, ... }:
{
  imports = [
    ./configuration.nix
    inputs.home-manager.nixosModules.default
  ];
}
