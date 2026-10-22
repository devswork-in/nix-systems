{ pkgs, lib, userConfig, ... }:

{
  imports = [
    ../../profiles/server.nix
    ./hardware.nix
    ./gateway.nix
    ../../modules/services/website
  ];

  networking.hostName = "phoenix";

  # No x86 emulation needed on this server.
  boot.binfmt.emulatedSystems = lib.mkForce [];

  # Docker is not needed; the gateway runs as native systemd services.
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.docker.enableOnBoot = lib.mkForce false;
  virtualisation.docker.autoPrune.enable = lib.mkForce false;
  users.users.${userConfig.user.name} = {
    extraGroups = lib.mkForce [ "wheel" ];
    # Keep a user manager so switch-to-configuration can reload user units.
    linger = true;
  };

  # Storage safeguards: require >= 8 GiB free before any build.
  nix.settings = {
    min-free = 8 * 1024 * 1024 * 1024;
    max-free = 15 * 1024 * 1024 * 1024;
  };

  # Keep only 3 generations; GC weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # Disable nix-repo-sync on this host; dotfiles are managed manually.
  services.nix-repo-sync.enable = lib.mkForce false;

  # Extend module defaults: overriding them removes essential login/system tools.
  environment.systemPackages = with pkgs; [ just jekyll bundler ];
}
