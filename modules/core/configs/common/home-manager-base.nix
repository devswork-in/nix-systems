# Common home-manager configuration for all systems
# This provides the base home-manager setup that all systems inherit

{ userConfig, nixosVersion, ... }:

{
  home-manager = {
    # Common home-manager settings
    
    # Backup existing files instead of failing
    backupFileExtension = "backup";
    
    # Pass userConfig to all home-manager modules
    extraSpecialArgs = { inherit userConfig; };
    
    # Base user configuration (extended by specific configs)
    users."${userConfig.user.name}" = { ... }: {
      home = {
        username = "${userConfig.user.name}";
        homeDirectory = "/home/${userConfig.user.name}";
        stateVersion = "${nixosVersion}";
      };
      
      # Allow unfree packages in home-manager
      # Note: If using home-manager.useGlobalPkgs, this is inherited from system config
      nixpkgs.config.allowUnfree = true;
    };
  };
}
