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

  # Phoenix deploys Compose workloads through its single rootful Docker daemon.
  users.users.${userConfig.user.name}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    pnpm
    just
  ];
}
