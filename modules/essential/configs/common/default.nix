# Common configuration files for all systems
{ config, pkgs, ... }:

{
  imports = [
    ./symlinks.nix
    ./environment.nix
  ];

  # Fish shell configuration (can be overridden by addon configs)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Source our external fish config
      ${builtins.readFile ./fish/config.fish}
      
      # Common fish configuration
      set -g fish_greeting
    '';
  };
  
  # Tmux configuration (can be overridden by addon configs)
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Common tmux configuration
      set -g mouse on
      set -g status-bg colour235
    '';
  };
}