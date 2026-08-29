# Common packages that most systems need
{ pkgs, ... }:

{
  imports = [
    #./awrit.nix
    ./bat.nix
    ./direnv.nix
    ./fonts.nix
    ./fzf.nix
    ./git.nix
    ./mcfly.nix
    ./monocle.nix
    ./nnn.nix
    ./nvim.nix
  ];

  environment.systemPackages = with pkgs; [
    htop
    jq
    lazygit
    starship
    wget
    github-cli
    aria2
    libclang
    gcc
    gnumake
    ripgrep
    smartmontools
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
    bun
    tree
    tmux
    lsof
    eva
    uv  # Python package manager
  ];
}
