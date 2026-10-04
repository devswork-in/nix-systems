{ pkgs, lib, inputs, userConfig, ... }:

{
  imports = [
    # Import server profile (provides common server configuration)
    ../../profiles/server.nix
    
    # System-specific modules
    ./hardware.nix
    
    # Addon modules
    ../../modules/services/website
  ];

  # System-specific configuration
  networking.hostName = "phoenix";
  boot.binfmt.emulatedSystems = lib.mkIf (pkgs.system == "aarch64-linux") [ "x86_64-linux" ];

  # Phoenix deploys Compose workloads through its single rootful Docker daemon.
  users.users.${userConfig.user.name}.extraGroups = [ "docker" ];

  # Storage safeguards: enforce policy requirement of >= 8 GiB free
  nix.settings = {
    min-free = 8 * 1024 * 1024 * 1024;
    max-free = 15 * 1024 * 1024 * 1024;
  };

  # Tighter GC retention for cloud server (3 days instead of default 7 days)
  nix.gc = {
    options = "--delete-older-than 3d";
  };

  environment.systemPackages = with pkgs; [
    pnpm
    just
    bun
  ];
}
