# Complete server configuration
# Servers use nix-repo-sync for user configs.
{ userConfig, pkgs, ... }:

{
  # Keep the server role intentionally smaller than the desktop core.
  imports = [
    ../core/networking
    ../core/services.nix
  ];

  # Server packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    htop
    github-cli
    nnn
    starship
    aria2
    fzf
    ripgrep
    smartmontools
    jq
    direnv
    eva
    unzip
    fd
    progress
    lm_sensors
    duf
    gdu
    dig
    pciutils
    nix-index
    entr
    glow
    fff
    acpi
    axel
    python3
    tree
    lsof
    
    # Website building tools
    jekyll
    bundler
    
    # bat and extras
    bat
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batwatch
    bat-extras.prettybat
    bat-extras.batdiff
    
    # neovim
    neovim
    luajit
    
    # mcfly for shell history
    mcfly
  ];

  # Enable neovim with vim alias (native NixOS)
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
