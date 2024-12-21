{ pkgs, lib, ... }:
let config = import ./../../config.nix { };
in {
  environment.systemPackages = with pkgs; [ cachix home-manager ];
  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = lib.mkDefault "server";
    nameservers = [ "8.8.4.4" "8.8.8.8" "1.1.1.1" "9.9.9.9" ];
    firewall.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  programs.fish.enable = true;

  nix = {
    gc = {
      automatic =
        true; # runs nix-collect-garbage which removes old unrefrenced packages
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ]; # enable flakes
      substituters = [
        "https://cache.nixos.org"
        "https://nixpkgs.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store =
        true; # automatically detects files in the store that have identical contents and replaces with hard links.
      trusted-users = [ "root" "${config.userName}" ]; # for cachix to work
    };
  };

  nixpkgs.config.allowUnfree = true;

  users.users = {
    root = {
      shell = pkgs.fish;
      hashedPassword = config.hashedPassword;
      openssh.authorizedKeys.keys = config.sshKeys;
    };
    "${config.userName}" = {
      shell = pkgs.fish;
      group = "users";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      hashedPassword = config.hashedPassword;
      openssh.authorizedKeys.keys = config.sshKeys;
    };
  };

  swapDevices = [{
    device = "/swapfile";
    size = 4096;
  }];
  system.stateVersion = config.nixosReleaseVersion;
}
