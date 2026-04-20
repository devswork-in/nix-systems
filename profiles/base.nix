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

      # Don't keep derivations after builds — saves store space and speeds path resolution
      keep-derivations = false;

      # Don't keep build outputs — reduces store bloat over time
      keep-outputs = false;

      # Optimize store by checking for duplicates more aggressively
      min-free = lib.mkDefault (1 * 1024 * 1024 * 1024); # 1GB — triggers GC when below
      max-free = lib.mkDefault (50 * 1024 * 1024 * 1024); # 50GB — stops GC when above

      # Trusted users for nix operations
      trusted-users = [ "root" userConfig.user.name ];

      # Increase download buffer to avoid "buffer is full" warnings
      download-buffer-size = 524288000;
    };
  };

  # nixpkgs.config (allowUnfree, allowInsecure) is set in lib/mkSystemConfig.nix

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

  # Journald optimization - rate limiting to reduce I/O overhead
  # Prevents log flooding from consuming disk I/O bandwidth
  services.journald = {
    rateLimitBurst = lib.mkDefault 500; # Messages per interval (default 200)
    rateLimitInterval = lib.mkDefault "30s"; # Rate limit window (default 30s)
    extraConfig = lib.mkDefault ''
      Storage=persistent
      Compress=yes
      SystemMaxUse=500M
      MaxRetentionSec=1month
      ForwardToConsole=no
    '';
  };

  # Built-in automatic cleanup for coredumps
  systemd.coredump.extraConfig = ''
    Storage=external
    MaxUse=1G
    KeepFree=10G
  '';

  # Ensure journal directory has correct permissions
  systemd.tmpfiles.rules = [
    "z /var/log/journal 2755 root systemd-journal - -"
  ];

  # System state version (derived from flake nixpkgs input)
  system.stateVersion = nixosVersion;

  # Ensure nix-repo-sync has access to git and ssh
  # Run it on a timer to avoid blocking boot
  systemd.services.nix-repo-sync = {
    path = with pkgs; [ git openssh ];
    wantedBy = lib.mkForce [ ]; # Don't start at boot
  };

  # Create symlink for bash in /bin/bash for compatibility with scripts
  system.activationScripts.create-bin-bash = {
    text = ''
      # Ensure /bin/bash exists as a symlink to the installed bash
      mkdir -p /bin
      rm -f /bin/bash  # Remove if it exists (whether file or broken symlink)
      ln -s ${pkgs.bash}/bin/bash /bin/bash
    '';
    deps = [ ];
  };

  systemd.timers.nix-repo-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = lib.mkForce "1m";
      Unit = "nix-repo-sync.service";
    };
  };
}
