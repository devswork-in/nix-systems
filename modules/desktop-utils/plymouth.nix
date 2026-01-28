{ pkgs, ... }:

{
  boot = {
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "splash"
      "vga=current"
      "udev.log_priority=3"
      "fbcon=nodefer"
      "vt.global_cursor_default=0"
      "nowatchdog"
      "modprobe.blacklist=iTCO_wdt"
      "plymouth.force-splash"
    ];
    consoleLogLevel = 0;
    plymouth = {
      enable = true;
      # "bgrt" is the default theme that uses the UEFI/BIOS logo
      theme = "bgrt";
    };
    initrd.verbose = false;
  };
}
