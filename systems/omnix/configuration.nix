{ pkgs, lib, userConfig, inputs, ... }:

{
  imports = [
    # Import desktop profile (provides common desktop configuration)
    ../../profiles/desktop.nix

    # System-specific modules
    ./ollama.nix
    ./hardware.nix
    ../../modules/core/vars/omnix.nix
    ./hibernation.nix
    ./fileSystems.nix

    # Core session management
    ../../modules/core/session-manager.nix

    # Addon modules
    ../../modules/services
#    ../../modules/desktops/wayland/niri
    ../../modules/desktops/x11/dwm
    ../../modules/desktop-utils/services.nix
    ../../modules/desktop-utils/plymouth.nix
    ../../modules/desktop-utils/tlp.nix
    ../../modules/desktop-utils/performance-optimization.nix
    # ../../modules/apps/kiro
    ../../modules/extras/kernels/zen.nix
  ];

  # Disable GDM - using TTY auto-login with session-manager
  services.xserver.displayManager.gdm.enable = lib.mkForce false;

  # Add NUR overlay for Firefox extensions
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  # Ensure home-manager uses the same pkgs with overlays
  home-manager.useGlobalPkgs = true;

  # Backup existing files instead of failing
  home-manager.backupFileExtension = "backup";

  # System-specific hostname (overrides profile default)
  networking.hostName = "omnix";

  # System-specific packages
  environment.systemPackages = with pkgs; [ amdgpu_top gparted ntfs3g ];

  # Performance optimizations for faster app launches
  systemd.services = {
    # Reduce systemd timeout for faster boot/shutdown
    systemd-user-sessions.serviceConfig.TimeoutStartSec = "5s";
  };

  # Enable fstrim for SSD performance
  services.fstrim.enable = true;

  # System-specific user groups (extends profile groups)
  users.users.${userConfig.user.name}.extraGroups = [ "input" ];

  # Optimize I/O scheduler for faster app loading
  services.udev.extraRules = ''
    # Set I/O scheduler to none for NVMe (best for NVMe SSDs - faster app loading)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"

    # Ensure input devices are accessible for fusuma gestures
    KERNEL=="event*", SUBSYSTEM=="input", MODE="0660", GROUP="input"
  '';

  # Enable performance optimizations with balanced profile
  performance-optimization = {
    enable = true;
    profile = "balanced"; # Options: "balanced", "responsive", "quiet"
  };
}
