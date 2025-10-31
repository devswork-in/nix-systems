# System profiles for NixOS configurations
# This module exports all available system profiles

{
  # Base profile - common settings for all systems
  base = import ./base.nix;
  
  # Desktop profile - settings for desktop/laptop systems
  desktop = import ./desktop.nix;
  
  # Server profile - settings for server systems
  server = import ./server.nix;
}
