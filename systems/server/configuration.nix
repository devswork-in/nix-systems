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

  # Example: Override or extend repo sync items for this specific server
  # services.repoSync.syncItems = lib.mkForce [
  #   # Add system-specific repos here
  #   {
  #     type = "git";
  #     url = "https://github.com/user/custom-repo";
  #     dest = "/var/www/custom";
  #   }
  # ];
  
  # Or append to defaults:
  # services.repoSync.syncItems = lib.mkDefault (
  #   config.services.repoSync.syncItems ++ [
  #     { type = "git"; url = "..."; dest = "..."; }
  #   ]
  # );
}
