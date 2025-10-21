# All essential configurations including the minimal user setup
{ ... }:

{
  imports = [
    ./core
    ./networking
    ./security
    ./configs/minimal
  ];
}