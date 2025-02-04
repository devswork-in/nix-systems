{ config, ... }:
{
  imports = [
    ./wireguard.nix
    ./hosts.nix
  ];
}
