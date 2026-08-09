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
    ../../modules/core/services/rtk-setup.nix

    # Omnix services
    ../../modules/services/steam.nix
    ../../modules/services/virtManager.nix
    ../../modules/desktops/wayland/niri
    ../../modules/desktop-utils/services.nix
    ../../modules/desktop-utils/plymouth.nix
    ../../modules/desktop-utils/tlp.nix
    ../../modules/desktop-utils/performance-optimization.nix
    # ../../modules/apps/kiro
    ../../modules/apps/voquill
  ];

  # Disable GDM - using TTY auto-login with session-manager
  services.displayManager.gdm.enable = lib.mkForce false;

  # System-specific hostname (overrides profile default)
  networking.hostName = "omnix";

  nix.settings.min-free = 10 * 1024 * 1024 * 1024;

  # Ignore DHCP DNS servers to bypass stale local/ISP records
  # This forces use of global nameservers (8.8.8.8, etc.) defined in desktop profile
  networking.networkmanager.dns = "none";

  services.tailscale.enable = true;

  # System-specific packages
  environment.systemPackages = with pkgs; [ gparted ntfs3g ];

  # Performance optimizations for faster app launches
  systemd.services = {
    # Reduce systemd timeout for faster boot/shutdown
    systemd-user-sessions.serviceConfig.TimeoutStartSec = "5s";
  };

  # Enable fstrim for SSD performance
  services.fstrim.enable = true;

  # CachyOS kernel from the upstream cached flake input.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # Enable QEMU binfmt emulation for cross-architecture builds (e.g., aarch64)
  # Required for building phoenix-arm (aarch64-linux) images on omnix (x86_64-linux)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Full kernel preemption for lower desktop latency (snappier apps, less input lag)
  boot.kernelParams = [ "preempt=full" ];

  # Note: amd-pstate-epp only supports 'performance' and 'powersave' governors.
  # Actual performance is controlled by EPP preference in TLP config.

  programs.voquill.enable = true;

  # Omnix is an AMD/Niri system. Keep X11 and Intel-only thermald off here,
  # without changing the dormant Intel desktop configuration.
  services.xserver.enable = lib.mkForce false;
  services.xserver.displayManager.sx.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;

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
    profile = "responsive"; # Options: "balanced", "responsive", "quiet"
  };

  # Disable KSM (memory dedup for VMs) — not needed without VMs, saves boot time
  systemd.services.ksm-enable.enable = lib.mkForce false;
}
