{ pkgs, inputs, userConfig, ... }:

{
  imports = [
    # Import server profile (provides common server configuration)
    ../../profiles/server.nix
    
    # System-specific modules
    ../server/hardware-configuration.nix
    
    # Addon modules
    ../../modules/services/website
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "phoenix";
}
