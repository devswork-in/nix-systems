# Base profile - Common configuration for all systems
# This profile contains settings shared across all NixOS systems

{ config, pkgs, lib, userConfig, nixosVersion, ... }:

{
  # Nix settings common to all systems
  imports = [ ../modules/services/docker ../modules/core/vars/default.nix ];

  nix = {
    settings = {
      # Enable flakes and nix-command
      experimental-features = [ "nix-command" "flakes" ];

      # Common binary caches
      substituters = [
        "file:///home/${userConfig.user.name}/.nix-cache"
        "https://cache.nixos.org"
        "https://nixpkgs.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.iog.io"
        "https://cache.garnix.io?priority=41"
        "https://numtide.cachix.org"
      ];

      # Trusted public keys for binary caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
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
    vim
    fishPlugins.foreign-env
    openssh
  ];

  # Configure vim and set as default editor
  programs.vim = {
    enable = true;
    defaultEditor = true; # This sets EDITOR and VISUAL to vim
  };

  # Default timezone (can be overridden per-system)
  time.timeZone = lib.mkDefault "Asia/Kolkata";

  # Default locale (can be overridden per-system)
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # System state version (derived from flake nixpkgs input)
  system.stateVersion = nixosVersion;

  # Ensure nix-repo-sync has access to git and ssh
  systemd.services.nix-repo-sync = { path = with pkgs; [ git openssh ]; };
}
