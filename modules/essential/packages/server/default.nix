# Server-specific packages and configurations
{ pkgs, ... }:

{
  imports = [
    ../common  # Import common packages
    ../../configs/server  # Import server configs
  ];

  # Add only server-specific packages not in common
  home.packages = with pkgs; [
    # Add any server-specific packages here
  ];

  # Server-specific configurations can go here
  nixpkgs.config.allowUnfree = true;
}