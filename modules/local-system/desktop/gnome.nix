{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      displayManager = {
        defaultSession = "gnome";
	gdm.enable = true;
      };
      desktopManager.gnome.enable = true;
    };
  };

    environment.systemPackages = with pkgs;
    with gnomeExtensions; [
      gnome3.dconf-editor
      gnome3.gnome-tweaks
    ];

  # exclude some default applications
  environment.gnome.excludePackages = with pkgs; [
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.totem
    gnome3.epiphany
  ];
  programs = {
    gnome-terminal.enable = false;
    geary.enable = false;
  };

  services.power-profiles-daemon.enable = false;
}
