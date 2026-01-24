{ pkgs, ... }:

{
  services.udiskie = {
    enable = true;
    tray = "auto";
    notify = true;
    automount = true;
    settings = {
      program_options = { udisks_version = 2; };
      icon_names = { media = [ "drive-removable-media" ]; };
    };
  };
}
