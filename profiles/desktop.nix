# Desktop profile - Common configuration for desktop/laptop systems
# This profile contains settings shared across all desktop NixOS systems

{ config, pkgs, lib, userConfig, flakeRoot, inputs, ... }:

{
  # Import base profile
  imports = [
    ./base.nix
    ../modules/core/vars/desktop.nix
    ../modules/services/flatpak.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  # Boot configuration common to desktops
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        memtest86.enable = lib.mkDefault true;
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
  # Disabled by default to keep more generations during development
  nix.gc = {
    automatic = lib.mkDefault false;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Hardware clock in local time (useful for dual-boot with Windows)
  time.hardwareClockInLocalTime = true;

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
      ++ (syncConfig.${config.networking.hostName} or [ ]));
  };
}
