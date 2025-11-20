# Server-specific packages and configurations
{ pkgs, ... }:

{
  imports = [
    ../../core/packages  # Import common packages
  ];

  # Add only server-specific packages not in common
  home.packages = with pkgs; [
    # Add any server-specific packages here
  ];

  # Server-specific configurations can go here
}