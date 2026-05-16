{ pkgs, lib, userConfig, ... }:

{
  imports = [
    # Import desktop profile (provides common desktop configuration)
    ../../profiles/desktop.nix
    
    # System-specific modules
    ./hardware.nix
    ./fileSystems.nix
    
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "blade";

  # Example: Override sync items for this system
  # services.nix-repo-sync.syncItems = lib.mkForce [ /* ... */ ];
  

}
