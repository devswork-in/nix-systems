# Common packages that most systems need
{ pkgs, ... }:

{
  imports = [
    ./awrit.nix
    ./bat.nix
    ./direnv.nix
    ./fonts.nix
    ./fzf.nix
    ./git.nix
    ./mcfly.nix
    ./nvim.nix
  ];

  # Simple programs.X.enable (no extra config needed)
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    wget
    github-cli
    nnn
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
    tree
    tmux
    lsof
    eva
    uv  # Python package manager
  ];
}
