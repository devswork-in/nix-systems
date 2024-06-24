{ pkgs, inputs, ... }:
{
  imports = [
    ./../server/configuration.nix
    ./../server/hardware-configuration.nix
    ./../../modules/home-manager
    inputs.home-manager.nixosModules.default
  ];

  #add on top of ./../server/configuration.nix
  environment.systemPackages = with pkgs; [ git ];
}
