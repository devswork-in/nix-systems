{ pkgs, lib, ... }:

{
  services = {
    # Essential SSH service
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "yes";
      };
    };
    
    # Limit journal size to save space
    journald.extraConfig = "SystemMaxUse=100M";
    
    # Power management rules (some apply to servers too)
    udev.extraRules = lib.mkMerge [
      # Autosuspend USB devices to save power after a period of inactivity
      ''
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
      ''

      # Autosuspend PCI devices to save power after a period of inactivity
      ''
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
      ''
    ];
  };

  programs = {
    # Essential build tool
    ccache.enable = true;
    
    # Run unpatched dynamic binaries on NixOS
    nix-ld.enable = true;
  };
}