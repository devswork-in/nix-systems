# Default configuration for a minimal server setup
{ ... }:

{
  imports = [
    ./core
    ./networking
    ./security
    ./configs/minimal
  ];
}