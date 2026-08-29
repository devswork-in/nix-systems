# Complete desktop configuration
{ lib, ... }:

{
  imports = [
    ../core
    ../apps/appimages
    ./packages
    ./fusuma.nix
    ./udiskie.nix
    ./nightlight.nix
  ];

  # Default enable nightlight
  nightlight.enable = lib.mkDefault true;

  # CopyQ removed - using Vicinae clipboard manager instead
  # services.copyq.enable = true;

}
