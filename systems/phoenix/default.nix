{ pkgs, inputs, ... }:
{
  imports = [
    ./../server/configuration.nix
    ./../server/hardware-configuration.nix
    ./../../modules/docker
    ./../../modules/website
  ];

  #add on top of ./../server/configuration.nix
  networking.hostName = "phoenix";
  environment.systemPackages = with pkgs; [ git ];
}
