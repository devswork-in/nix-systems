# Desktop-specific configuration files
{ config, pkgs, ... }:

{
  imports = [
    ./fusuma.nix
  ];

  # Additional fish functions/configs for desktop
  programs.fish = {
    interactiveShellInit = ''
      # Desktop-specific fish functions
      # Add desktop-specific aliases here
    '';
  };
  

  
  # Additional desktop config files
  home.file = {
    # Starship prompt configuration
    ".config/starship.toml".text = ''
      # Starship configuration
      add_newline = true
      [character]
      success_symbol = "[→](bold green)"
      error_symbol = "[→](bold red)"
    '';
  };
}
