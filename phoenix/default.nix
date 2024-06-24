{ pkgs, ... }:
{
  imports = [
    ./../server/configuration.nix
    ./../server/hardware-configuration.nix
  ];

  #add on top of ./../server/configuration.nix
  environment.systemPackages = with pkgs; [ git ];
}
