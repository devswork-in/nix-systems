# Library functions for NixOS configuration
# This module exports all helper functions used across the configuration

{ pkgs ? import <nixpkgs> { } }:

{
  # Helper function to create AppImage packages with desktop integration
  # Extracted from modules/addons/apps/appimages/default.nix
  mkAppImage = import ./mkAppImage.nix { inherit pkgs; };

  # Helper function to create NixOS system configurations
  # Simplifies system creation in flake.nix
  mkSystemConfig = import ./mkSystemConfig.nix;
}
