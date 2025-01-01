{ pkgs, lib, ... }:
let
  config = import ./../../config.nix {};
in
{
  imports = [
    ./hardware.nix
    ./fileSystems.nix
    ./../../modules/docker
    ./../../modules/steam.nix
    ./../../modules/hosts.nix
    ./../../modules/snaps.nix
    ./../../modules/flatpak.nix
    ./../../modules/local-system
    ./../../modules/wireguard.nix
    ./../../modules/virtManager.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86 = {
          enable = true;
        };
      };
      timeout = 0; #press Esc while booting if things get messy
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = lib.mkDefault "omnix";
    nameservers = ["8.8.8.8" "9.9.9.9" "1.1.1.1" "8.8.4.4"];
  };

  #https://discourse.nixos.org/t/fish-shell-and-manual-page-completion-nixos-home-manager/15661/3
  documentation.man.generateCaches = true;

  environment = {
    systemPackages = with pkgs; [ home-manager amdgpu_top ];
    pathsToLink = [ "/share/fish" ];
  };

  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_US.UTF-8";

  programs.fish.enable = true;
  users.users.${config.userName} = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "input" "power" "storage" "wheel" "audio" "video" "networkmanager" ];
    hashedPassword = config.hashedPassword;
  };

  security.allowSimultaneousMultithreading = true;

  nix = {
    # Keep garbage collection disabled until ! pure
    #gc = {
    #  automatic = false; 				# runs nix-collect-garbage which removes old unrefrenced packages
    #  dates = "weekly";
    #  options = "--delete-older-than 7d";
    #};
    settings = {
      experimental-features = [ "nix-command" "flakes" ]; #enable flakes
      substituters = [
        "https://cache.nixos.org"
        "https://nixpkgs.cachix.org"
        "https://nix-community.cachix.org"
        "file:///home/${config.userName}/.nix-cache"
        "https://cache.iog.io"
        "https://cache.garnix.io?priority=41"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      auto-optimise-store = true; #automatically detects files in the store that have identical contents and replaces with hard links.
      trusted-users = [ "root" "${config.userName}" ]; #for cachix to work
    };
  };

  nixpkgs.config.allowUnfree = true;
  time.hardwareClockInLocalTime = true;
  system.stateVersion = "${config.nixosReleaseVersion}";
}

