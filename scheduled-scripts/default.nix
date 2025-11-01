{ config, pkgs, lib, ... }:

{
  imports = [
    ./scheduled-commands.nix
  ];
}
