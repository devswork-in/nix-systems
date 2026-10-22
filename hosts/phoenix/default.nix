{ pkgs, lib, userConfig, ... }:

{
  imports = [
    ../../profiles/server.nix
    ./hardware.nix
    ./gateway.nix
    ../../modules/services/website
  ];

  networking.hostName = "phoenix";

  # No x86 emulation needed on this server.
  boot.binfmt.emulatedSystems = lib.mkForce [];

  # Docker is not needed; the gateway runs as native systemd services.
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.docker.enableOnBoot = lib.mkForce false;
  virtualisation.docker.autoPrune.enable = lib.mkForce false;
  users.users.${userConfig.user.name}.extraGroups =
    lib.mkForce [ "wheel" ];

  # Storage safeguards: require >= 8 GiB free before any build.
  nix.settings = {
    min-free = 8 * 1024 * 1024 * 1024;
    max-free = 15 * 1024 * 1024 * 1024;
  };

  # Keep only 3 generations; GC weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # Disable nix-repo-sync on this host; dotfiles are managed manually.
  services.nix-repo-sync.enable = lib.mkForce false;

  # Override all server/base packages for Phoenix: drop bat-extras (brings in
  # rustc+clang = 3.8 GiB), prettybat, python3, nodejs, nix-index, fff, pnpm,
  # bun, cachix, docker-compose. Keep only what this host actually needs.
  environment.systemPackages = lib.mkForce (with pkgs; [
    # From base.nix
    # mkForce also drops module-added packages; fish is the login shell and
    # sshd rejects users whose shell is missing.
    git vim fish fishPlugins.foreign-env openssh android-tools
    # From server profile (trimmed)
    wget htop github-cli starship aria2 fzf ripgrep jq
    unzip fd progress lm_sensors duf gdu dig pciutils
    entr glow acpi axel tree lsof bat mcfly
    # Phoenix-specific
    just jekyll bundler
  ]);
}
