# Desktop profile - Common configuration for desktop/laptop systems
# This profile contains settings shared across all desktop NixOS systems

{ config, pkgs, lib, userConfig, flakeRoot, inputs, ... }:

{
  # Import base profile
  imports = [
    ./base.nix
    ../modules/core/vars/desktop.nix
    ../modules/services/audio.nix
    ../modules/services/flatpak.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # Add NUR overlay for Firefox extensions
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  # Home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  # Boot configuration common to desktops
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        memtest86.enable = lib.mkDefault true;
        configurationLimit = lib.mkDefault 2; # Keep only 2 boot entries
      };
      timeout = lib.mkDefault 0; # Press Esc while booting if needed
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    tmp.cleanOnBoot = lib.mkDefault true;
  };

  # Networking configuration for desktops
  networking = {
    networkmanager.enable = lib.mkDefault true;
    nameservers = lib.mkDefault [ "8.8.8.8" "9.9.9.9" "1.1.1.1" "8.8.4.4" ];
  };

  # Enable man page generation and caching for fish completion
  documentation.man.generateCaches = true;

  # Desktop environment configuration
  environment = {
    pathsToLink = [ "/share/fish" ]; # For fish shell completions
  };

  # User configuration for desktop systems
  users.users.${userConfig.user.name} = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups =
      [ "power" "storage" "wheel" "audio" "video" "networkmanager" ];
    hashedPassword = userConfig.user.hashedPassword;
  };

  # Allow simultaneous multithreading (SMT/Hyper-Threading)
  security.allowSimultaneousMultithreading = true;

  # Nix garbage collection settings for desktops
  # Only removes old generations (3d+), current imperative packages are safe
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 3d";
  };

  # Hardware clock in local time (useful for dual-boot with Windows)
  time.hardwareClockInLocalTime = true;

  # Readahead service - pre-loads common app files into page cache at boot
  services.readahead.enable = lib.mkDefault true;
  services.readahead.fileList = lib.mkDefault [
    # Shell and terminal tools
    "/run/current-system/sw/bin/fish"
    "/run/current-system/sw/bin/starship"
    "/run/current-system/sw/bin/bat"
    "/run/current-system/sw/bin/fzf"
    "/run/current-system/sw/bin/rg"
    # Editors and IDEs
    "/run/current-system/sw/bin/nvim"
    # System utilities
    "/run/current-system/sw/bin/git"
    "/run/current-system/sw/bin/htop"
    "/run/current-system/sw/bin/tmux"
    # Desktop apps (system-wide)
    "/run/current-system/sw/bin/kitty"
    "/run/current-system/sw/bin/niri"
    "/run/current-system/sw/bin/vicinae"
    "/run/current-system/sw/bin/zen-browser"
    "/run/current-system/sw/bin/nautilus"
    "/run/current-system/sw/bin/zathura"
  ];

  # Nix store pre-warm - warms store paths for frequently-used apps
  services.nix-store-prewarm.enable = lib.mkDefault true;
  services.nix-store-prewarm.packages = lib.mkDefault (with pkgs; [
    fish
    starship
    neovim
    git
    kitty
    niri
    vicinae
    google-chrome
    bat
    fzf
    ripgrep
    htop
    tmux
    nautilus
    zathura
  ]);
  services.nix-store-prewarm.delay = lib.mkDefault 15; # Wait 15s after boot

  # Configuration sync service (common + desktop syncs)
  services.nix-repo-sync = let
    syncConfig = import ../sync-config.nix {
      inherit (userConfig) user paths;
      inherit flakeRoot;
    };
  in {
    enable = lib.mkDefault true;
    user = userConfig.user.name;
    syncItems = lib.mkDefault ((syncConfig.common or [ ])
      ++ (syncConfig.desktop or [ ])
      ++ (syncConfig.${config.networking.hostName} or [ ])
      ++ (lib.optionals config.programs.niri.enable (syncConfig.niri or [ ])));
  };
}
