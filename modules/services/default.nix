{ config, ... }:
{
  imports = [
    ./steam.nix
    ./flatpak.nix
    ./virtManager.nix
    ./snaps.nix
  ];
}
