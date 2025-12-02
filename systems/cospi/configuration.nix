{ pkgs, lib, userConfig, ... }:

{
  imports = [
    # Import desktop profile (provides common desktop configuration)
    ../../profiles/desktop.nix
    
    # System-specific modules
    ./hardware.nix
    ./fileSystems.nix
    
    # Addon modules
    ../../modules/services/snaps.nix
    ../../modules/desktop/pop-shell.nix
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "cospi";
  

}
