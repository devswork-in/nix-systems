{ config, ... }:
{
  imports = [
    ./wireguard.nix
    ./hosts.nix
  ];

  # Disable services not needed for typical WiFi-only laptops
  # These can be enabled in specific configurations if needed
  services.avahi = {
    enable = false;  # Not typically needed on WiFi laptops
  };

  # Disable Bluetooth if not needed (can be enabled in specific configs)
  # hardware.bluetooth.enable = false;
  # services.blueman.enable = false;
}
