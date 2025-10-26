{ pkgs, ... }:

{
  # Additional boot time optimizations
  boot = {
    # Use deadline or none I/O scheduler for faster boot (deadline is more responsive, none for SSDs)
    kernel.sysctl = {
      "kernel.sched_migration_cost_ns" = "5000000";  # Reduce scheduler overhead
      "vm.swappiness" = 1;  # Minimize swapping
      "vm.vfs_cache_pressure" = 50;  # Reduce pressure to reclaim directory cache
    };
    
    # Reduce timeouts that can slow down boot
    loader.timeout = 1; # Reduce GRUB timeout to 1 second (was 0 which means no timeout)
  };

  # Services optimization
  services = {
    # Reduce systemd default timeouts
    udev = {
      enable = true;
      extraRules = ''
        # Optimize storage devices for performance during boot
        ACTION=="add", SUBSYSTEM=="scsi", ATTR{queue/scheduler}="none"
        ACTION=="add", SUBSYSTEM=="block", ATTR{queue/scheduler}="none"
      '';
    };
  };

  # systemd-specific optimizations
  systemd = {
    # Reduce systemd service timeouts to avoid waiting during boot
    user.services = {
      "systemd-user-sessions".timeoutStopSec = 1;
    };
    
    # Reduce timeouts for common services
    services = {
      ModemManager = {
        timeoutStartSec = "30s";
        timeoutStopSec = "10s";
      };
    };
  };
}