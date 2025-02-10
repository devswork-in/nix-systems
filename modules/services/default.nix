{ config, ... }:
{
  imports = [
    ./steam.nix
    ./mysql.nix
    ./flatpak.nix
    ./virtManager.nix
    ./snaps.nix
  ];
}
