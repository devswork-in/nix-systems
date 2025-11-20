{ pkgs, ... }:

{
  imports = [
    ./base
    ./networking
    ./command-scheduler/command-scheduler.nix
    ./services.nix
  ];

  # Additional essential system configurations can go here
  environment.systemPackages = with pkgs; [
    # Add any essential system packages here
  ];
}