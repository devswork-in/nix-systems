# Common configuration files for all systems
{ config, pkgs, ... }:

{
  imports = [
    ./symlinks.nix
    ./environment.nix
  ];
  
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