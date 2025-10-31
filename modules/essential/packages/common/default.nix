# Common packages that most systems need
{ pkgs, ... }:

{
  imports = [
    ./bat.nix
    ./fonts.nix
    ./mcfly.nix
    ./git.nix
    ./nvim.nix
    ../../configs/common
  ];

  home.packages = with pkgs; [
    wget
    htop
    github-cli
    nnn
    starship
    aria2
    libclang
    gcc
    gnumake
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
    xclip
    dig
    pciutils
    nix-index
    entr
    imgp
    recode
    glow
    fff
    acpi
    axel
    python3
    tree
    tmux
  ];

  nixpkgs.config.allowUnfree = true;
}