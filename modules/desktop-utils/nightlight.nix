{ config, lib, ... }:

{
  # Unified Nightlight Module (Arch-style modularity)
  
  # Backend for Wayland (Niri, Hyprland, etc.)
  services.wlsunset = {
    enable = true;
    latitude = "12.9";
    longitude = "77.5";
    temperature = {
      day = 5500;
      night = 4000;
    };
  };

  # Backend for X11 (DWM, etc.)
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 12.9719;
    longitude = 77.5937;
    temperature = {
      day = 5500;
      night = 4300;
    };
  };

  # Prevent both from starting automatically via systemd's default target
  # This ensures they only start when called by our session scripts/toggle
  systemd.user.services.wlsunset.Install.WantedBy = lib.mkForce [ ];
  systemd.user.services.gammastep.Install.WantedBy = lib.mkForce [ ];
}
