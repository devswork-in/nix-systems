# Server profile - Common configuration for server systems
# This profile contains settings shared across all server NixOS systems

{ config, pkgs, lib, userConfig, ... }:

{
  # Import base profile and repo-sync service
  imports = [
    ./base.nix
    ../modules/services/repo-sync
  ];

  # Boot configuration for servers
  boot.tmp.cleanOnBoot = true;

  # Networking configuration for servers
  networking = {
    firewall.enable = lib.mkDefault true;
    nameservers = lib.mkDefault [
      "8.8.4.4"
      "8.8.8.8"
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  # Server services
  services = {
    # SSH configuration
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    
    # Journal configuration to limit disk usage
    journald.extraConfig = "SystemMaxUse=100M";
  };

  # Nix garbage collection for servers
  # Enabled by default to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "daily";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # User configuration for servers
  users.users = {
    # Root user configuration
    root = {
      shell = pkgs.fish;
      hashedPassword = userConfig.user.hashedPassword;
      openssh.authorizedKeys.keys = userConfig.user.sshKeys;
    };
    
    # Regular user configuration
    "${userConfig.user.name}" = {
      shell = pkgs.fish;
      group = "users";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      hashedPassword = userConfig.user.hashedPassword;
      openssh.authorizedKeys.keys = userConfig.user.sshKeys;
    };
  };

  # Default swap configuration for servers
  swapDevices = lib.mkDefault [
    {
      device = "/swapfile";
      size = 4096;  # 4GB swap file
    }
  ];

  # Tmux configuration for servers
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Server tmux configuration
      set -g mouse on
      set -g status-bg colour235
    '';
  };

  # Enable tmux auto-start for servers
  environment.variables.TMUX_AUTO_START = "1";

  # Repository sync service for server-specific repos
  # Combines common syncs + server-specific syncs
  services.repoSync = {
    enable = lib.mkDefault true;
    user = userConfig.user.name;
    syncItems = lib.mkDefault (
      (userConfig.syncConfig.common or []) ++ 
      (userConfig.syncConfig.server or [])
    );
  };
}
