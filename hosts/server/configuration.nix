{ pkgs, lib, userConfig, ... }:

{
  imports = [
    # Import server profile (provides common server configuration)
    ../../profiles/server.nix
    
    # System-specific modules
    ./hardware-configuration.nix
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "server";

  # Example: Override sync items for this system
  # services.nix-repo-sync.syncItems = lib.mkForce [ /* ... */ ];
}
