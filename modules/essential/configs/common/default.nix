# Common configuration files for all systems
{ config, pkgs, ... }:

{
  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Common fish configuration
      set -g fish_greeting
    '';
  };
  
  # Tmux configuration
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Common tmux configuration
      set -g mouse on
      set -g status-bg colour235
    '';
  };
}