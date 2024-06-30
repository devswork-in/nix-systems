{ pkgs, inputs, ... }:
{
  imports = [
    ./../server/configuration.nix
    ./../server/hardware-configuration.nix
    ./../../modules/docker
    ./../../modules/website
    ./../../modules/home-manager
    inputs.home-manager.nixosModules.default
  ];

  #add on top of ./../server/configuration.nix
  networking.hostName = "phoenix";
  environment.systemPackages = with pkgs; [ git ];
}
