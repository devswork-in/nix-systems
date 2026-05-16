{ pkgs, lib, inputs, userConfig, ... }:

{
  imports = [
    # Import server profile (provides common server configuration)
    ../../profiles/server.nix
    
    # System-specific modules
    ../server/hardware-configuration.nix
    
    # Addon modules
    ../../modules/services/website
    ../../modules/services/docker
  ];

  # System-specific configuration
  networking.hostName = "phoenix";

  # Ensure nix-repo-sync has docker/just/git for loomwork postSync
  systemd.services.nix-repo-sync.path = with pkgs; [ git just docker-compose docker ];
  virtualisation.docker.enableOnBoot = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    pnpm
    just
  ];
}
