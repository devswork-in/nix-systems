{ pkgs, inputs, ... }:
{
  imports = [
    ./../server/configuration.nix
    ./../server/hardware-configuration.nix
    ./../../modules/home-manager
    ./../../modules/docker
    inputs.home-manager.nixosModules.default
  ];

  #add on top of ./../server/configuration.nix
  networking.hostName = "phoenix";
  environment.systemPackages = with pkgs; [ git ];
}
