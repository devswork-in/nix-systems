{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [ cachix home-manager ];
  boot.tmp.cleanOnBoot = true;

  networking = {
    nameservers = ["8.8.4.4" "8.8.8.8" "1.1.1.1" "9.9.9.9"];
    firewall.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  programs.fish.enable = true;

  nix = {
    gc = {
      automatic = true;                 # runs nix-collect-garbage which removes old unrefrenced packages
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ]; #enable flakes
      substituters = [
       "https://cache.nixos.org"
       "https://nixpkgs.cachix.org"
       "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true; #automatically detects files in the sto      re that have identical contents and replaces with hard links.
      trusted-users = [ "root" "creator54" ]; #for cachix to work
    };
  };

  nixpkgs.config.allowUnfree = true;

  users.users = {
    root = {
      shell = pkgs.fish;
      hashedPassword = "$y$j9T$xIo2r2i0pl55kKgQx0X5S1$0VtDoXgpYwcQieQ7pZ08rEhXRFHSPKgvkPw9OS4uTP3";
      openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9wiMgFixwVeBltzm9IaGtScIuuDvmfhqEShPXCvupyGfeXvKuovtHw28ZMF7C6bHCsfHZzIb71WCJFMoopIxqORW+H+Ya++UuT7kJ/vdm24qnPh4pj9wX159i7fUh3qIdL39sGYTIEFjL9zGjSYOhbx9b73W/sCREJ5NUx22HKYtKCESveWZJUiSxCmPL0MB9Xr3+IRfO0VTSteg76favRWrZ9MB2zpKAlEuUNwiqJR6Rbtc0XEVO2MmCfzdP3lfrRBPDXtx7F0tk76FnSts7jQDB6DVjWxdqRrh+jZzf3mg0nraoJ9W/H44ubOjtQGjfciANamEml0kGg2J00NrtDmzvm06M+G3H3GC7ylm8tAcz2AHZlMjRTxjLhxxSDCxGsCbLankJ0vAkqq2pmeBrCaJfcJzisblEEHKhoY1t7LUJHFboQ/XV5Bg6K8ZYMki2NAyOlO7FEOTzWE1+ZrYyqG85T9vifnVCiIAMVUR9aSXJF1Y04MkJV4o74eGPvGsRbWRLJ+wfnCkEzZgWNNEZOPiPM2eJeZFD4kn4+8aEpeavV7rVQAoWvlb2eQ1ZVsQwKghxsReJ0FjjTDA7NBxAnITsEoDnAnUdws9PfLeNTpoQ1pcv2HD3nq2LWGwd4u2Tv0cYwtjTyN6q5B7Qp6k2LV9FyMThWCjBRQyCTKT4Ww== hi.creator54@gmail.com'' ];
    };
    creator54 = {
      shell = pkgs.fish;
      group = "users";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      hashedPassword = "$y$j9T$xIo2r2i0pl55kKgQx0X5S1$0VtDoXgpYwcQieQ7pZ08rEhXRFHSPKgvkPw9OS4uTP3";
      openssh.authorizedKeys.keys = [''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9wiMgFixwVeBltzm9IaGtScIuuDvmfhqEShPXCvupyGfeXvKuovtHw28ZMF7C6bHCsfHZzIb71WCJFMoopIxqORW+H+Ya++UuT7kJ/vdm24qnPh4pj9wX159i7fUh3qIdL39sGYTIEFjL9zGjSYOhbx9b73W/sCREJ5NUx22HKYtKCESveWZJUiSxCmPL0MB9Xr3+IRfO0VTSteg76favRWrZ9MB2zpKAlEuUNwiqJR6Rbtc0XEVO2MmCfzdP3lfrRBPDXtx7F0tk76FnSts7jQDB6DVjWxdqRrh+jZzf3mg0nraoJ9W/H44ubOjtQGjfciANamEml0kGg2J00NrtDmzvm06M+G3H3GC7ylm8tAcz2AHZlMjRTxjLhxxSDCxGsCbLankJ0vAkqq2pmeBrCaJfcJzisblEEHKhoY1t7LUJHFboQ/XV5Bg6K8ZYMki2NAyOlO7FEOTzWE1+ZrYyqG85T9vifnVCiIAMVUR9aSXJF1Y04MkJV4o74eGPvGsRbWRLJ+wfnCkEzZgWNNEZOPiPM2eJeZFD4kn4+8aEpeavV7rVQAoWvlb2eQ1ZVsQwKghxsReJ0FjjTDA7NBxAnITsEoDnAnUdws9PfLeNTpoQ1pcv2HD3nq2LWGwd4u2Tv0cYwtjTyN6q5B7Qp6k2LV9FyMThWCjBRQyCTKT4Ww== hi.creator54@gmail.com'' ];
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 4096; } ];
  system.stateVersion = "23.11";
}
