{ pkgs, ... }:

{
  # Additional boot time optimizations
  boot = {
    kernelParams = [
      # Additional boot speed optimizations (beyond what's in plymouth.nix)
      "systemd.unified_cgroup_hierarchy=1"
      "systemd.legacy_system_units=false"
      "init_on_alloc=0"
      "slab_min_order=0"
      "transparent_hugepage=never"
      # systemd-boot specific parameters
      "systemd.mask=systemd-rfkill.service"
      "systemd.mask=systemd-backlight@backlight:intel_backlight.service"
    ];
    
    # Kernel sysctl optimizations for boot performance
    kernel.sysctl = {
      "kernel.sched_migration_cost_ns" = "5000000";  # Reduce scheduler overhead
      "vm.swappiness" = 1;  # Minimize swapping
      "vm.vfs_cache_pressure" = 50;  # Reduce pressure to reclaim directory cache
    };
    
    # Additional systemd-boot optimizations (preserves existing timeout settings)
    loader.systemd-boot = {
      configurationLimit = 10; # Reduce number of boot entries to manage
      editor = false; # Disable boot entry editor for faster boot
    };
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