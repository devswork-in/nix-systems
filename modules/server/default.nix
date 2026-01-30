# Complete server configuration
# Note: Servers use nix-repo-sync for user configs instead of home-manager
{ userConfig, pkgs, ... }:

{
  # Import only the core modules that don't require home-manager
  # Note: command-scheduler is excluded as it uses home-manager for user services
  imports = [
    ../core/networking
    ../core/services.nix
  ];

  # Server packages (replaces home-manager home.packages)
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
