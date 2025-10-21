# Desktop-specific configuration files
{ config, pkgs, ... }:

{
  # Additional fish functions/configs for desktop
  programs.fish = {
    interactiveShellInit = ''
      # Desktop-specific fish functions
      # Add desktop-specific aliases here
    '';
  };
  

  
  # Additional desktop config files
  home.file = {
    # Kitty terminal configuration
    ".config/kitty/kitty.conf".text = ''
      # Desktop kitty configuration
      font_family      JetBrains Mono
      font_size        12.0
      background_opacity 0.95
    '';
    
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