{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./home.nix
  ];
}
