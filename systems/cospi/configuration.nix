{ pkgs, lib, userConfig, ... }:

{
  imports = [
    # Import desktop profile (provides common desktop configuration)
    ../../profiles/desktop.nix
    
    # System-specific modules
    ./hardware.nix
    ./fileSystems.nix
    
    # Addon modules
    ../../modules/addons/services/docker
    ../../modules/essential/networking
    ../../modules/essential/core
    ../../modules/addons/services/snaps.nix
    ../../modules/addons/services/flatpak.nix
    ../../modules/addons/desktop/pop-shell.nix
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "cospi";
  
  # System-specific nix caches (extends profile caches)
  nix.settings.substituters = [
    "file:///home/${userConfig.user.name}/.nix-cache"
    "https://cache.iog.io"
    "https://cache.garnix.io?priority=41"
  ];
  
  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
}
