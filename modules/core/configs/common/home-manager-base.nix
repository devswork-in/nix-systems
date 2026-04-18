# Common home-manager configuration for all systems
# This provides the base home-manager setup that all systems inherit

{ userConfig, nixosVersion, inputs, ... }:

{
  home-manager = {
    # Common home-manager settings
    
    # Backup existing files instead of failing
    backupFileExtension = "backup";
    
    # Pass userConfig and inputs to all home-manager modules
    extraSpecialArgs = { inherit userConfig inputs; };
    
    # Base user configuration (extended by specific configs)
    users."${userConfig.user.name}" = { ... }: {
      home = {
        username = "${userConfig.user.name}";
        homeDirectory = "/home/${userConfig.user.name}";
        stateVersion = "${nixosVersion}";
      };
      

    };
  };
}
