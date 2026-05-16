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
    ../../modules/core/services/nixos-config-sync.nix

    # Addon modules
    ../../modules/services
    ../../modules/desktops/wayland/niri
    ../../modules/desktop-utils/services.nix
    ../../modules/desktop-utils/plymouth.nix
    ../../modules/desktop-utils/tlp.nix
    ../../modules/desktop-utils/performance-optimization.nix
    # ../../modules/apps/kiro
    ../../modules/extras/kernels/latest.nix
  ];

  # Disable GDM - using TTY auto-login with session-manager
  services.displayManager.gdm.enable = lib.mkForce false;

  # System-specific hostname (overrides profile default)
  networking.hostName = "omnix";

  # Ignore DHCP DNS servers to bypass stale local/ISP records
  # This forces use of global nameservers (8.8.8.8, etc.) defined in desktop profile
  networking.networkmanager.dns = "none";

  services.tailscale.enable = true;

  # Defer tailscaled start until after boot completes (VPN not needed for login)
  systemd.services.tailscaled = {
    after = lib.mkForce [ "multi-user.target" "NetworkManager-wait-online.service" ];
    wantedBy = lib.mkForce [ ];
  };
  systemd.timers.tailscaled-delayed = {
    description = "Delay tailscaled start until after boot";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnActiveSec = "10s";
      Unit = "tailscaled.service";
    };
  };

  # System-specific packages
  environment.systemPackages = with pkgs; [ gparted ntfs3g ];

  # Performance optimizations for faster app launches
  systemd.services = {
    # Reduce systemd timeout for faster boot/shutdown
    systemd-user-sessions.serviceConfig.TimeoutStartSec = "5s";
  };

  # Enable fstrim for SSD performance
  services.fstrim.enable = true;

  # Enable QEMU binfmt emulation for cross-architecture builds (e.g., aarch64)
  # Required for building phoenix-arm (aarch64-linux) images on omnix (x86_64-linux)
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Full kernel preemption for lower desktop latency (snappier apps, less input lag)
  boot.kernelParams = [ "preempt=full" ];

  # Note: amd-pstate-epp only supports 'performance' and 'powersave' governors.
  # Actual performance is controlled by EPP preference in TLP config.

  # Defer binfmt registration until after boot (saves ~800ms on critical path)
  # aarch64 cross-builds still work, just not during very early boot
  systemd.services.systemd-binfmt = {
    after = lib.mkForce [ "multi-user.target" ];
    wantedBy = lib.mkForce [ ];
  };
  systemd.timers.systemd-binfmt-delayed = {
    description = "Delay binfmt registration until after boot";
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnActiveSec = "5s";
      Unit = "systemd-binfmt.service";
    };
  };

  # Fix for "sudo: PAM account management error" during boot
  # Disable the upstream nix-repo-sync activation script which attempts to use sudo before PAM is ready
  system.activationScripts.nixRepoSyncPreActivation.text = lib.mkForce "";

  # Allow passwordless sudo for nixos-config-sync script
  security.sudo.extraRules = [{
    users = [ userConfig.user.name ];
    commands = [
      { command = "/home/${userConfig.user.name}/.local/bin/nixos-config-sync"; options = [ "NOPASSWD" ]; }
    ];
  }];

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
