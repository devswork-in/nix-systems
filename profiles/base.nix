# Base profile - Common configuration for all systems
# This profile contains settings shared across all NixOS systems

{ config, pkgs, lib, userConfig, nixosVersion, ... }:

{
  # Nix settings common to all systems
  nix = {
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Common binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nixpkgs.cachix.org"
        "https://nix-community.cachix.org"
      ];
      
      # Trusted public keys for binary caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Automatically optimize store by hard-linking identical files
      auto-optimise-store = true;
      
      # Trusted users for nix operations
      trusted-users = [ "root" userConfig.user.name ];
    };
  };

  # Allow unfree packages (common requirement)
  nixpkgs.config.allowUnfree = true;
  
  # Enable fish shell globally
  programs.fish.enable = true;
  
  # Base packages for all systems
  environment.systemPackages = with pkgs; [
    git
    cachix
    home-manager
  ];
  
  # Default timezone (can be overridden per-system)
  time.timeZone = lib.mkDefault "Asia/Kolkata";
  
  # Default locale (can be overridden per-system)
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  
  # System state version (derived from flake nixpkgs input)
  system.stateVersion = nixosVersion;
}
