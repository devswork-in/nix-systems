# Server-specific configuration files
{ config, pkgs, ... }:

{
  # Server-specific bash settings
  programs.bash = {
    initExtra = ''
      # Server-specific bash config
      # Less verbose settings for server environments
    '';
  };
  
  # Server-specific git config
  programs.git.extraConfig = {
    init.defaultBranch = "main";
  };
  
  # Server-specific configurations
  home.file = {
    # Any server-specific config files
  };
}