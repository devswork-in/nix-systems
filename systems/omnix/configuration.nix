{ pkgs, lib, userConfig, ... }:

{
  imports = [
    # Import desktop profile (provides common desktop configuration)
    ../../profiles/desktop.nix
    
    # System-specific modules
    ./ollama.nix
    ./hardware.nix
    ./hibernation.nix
    ./fileSystems.nix
    
    # Addon modules
    ../../modules/addons/services/docker
    ../../modules/essential/core
    ../../modules/essential/networking
    ../../modules/addons/services
    ../../modules/addons/desktop/pop-shell.nix
    ../../modules/addons/apps/kiro
  ];

  # System-specific hostname (overrides profile default)
  networking.hostName = "omnix";
  
  # System-specific packages
  environment.systemPackages = with pkgs; [
    amdgpu_top
    gparted
  ];
  
  # System-specific user groups (extends profile groups)
  users.users.${userConfig.user.name}.extraGroups = [ "input" ];
  
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
