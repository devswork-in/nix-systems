{ config, lib, pkgs, userConfig, ... }:

with lib;

let
  cfg = config.performance-optimization;

  # Profile configurations
  profiles = {
    balanced = {
      swappiness = 60;
      minCpuFreqAC = 400000;
      cpuEPP = "balance_performance";
      compositorPriority = -10;
      zramPercent = 50;
      enableCpuBoostAC = true;
    };

    responsive = {
      swappiness = 60;
      minCpuFreqAC = 1400000;
      cpuEPP = "balance_performance";
      compositorPriority = -15;
      zramPercent = 50;
      enableCpuBoostAC = true;
    };

    quiet = {
      swappiness = 60;
      minCpuFreqAC = 400000;
      cpuEPP = "balance_power";
      compositorPriority = -5;
      zramPercent = 50;
      enableCpuBoostAC = false;
    };
  };

  activeProfile = profiles.${cfg.profile};

in {
  options.performance-optimization = {
    enable = mkEnableOption "system performance optimizations";

    profile = mkOption {
      type = types.enum [ "balanced" "responsive" "quiet" ];
      default = "balanced";
      description = ''
        Performance profile to use:
        - balanced: Good performance with reasonable thermals (default)
        - responsive: Maximum responsiveness, higher power usage
        - quiet: Lower performance, quieter operation, better battery life
      '';
    };

    kernel = {
      enableSysctlOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kernel sysctl parameter optimizations";
      };

      enableBootOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kernel boot parameter optimizations";
      };

      disableMitigations = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Disable CPU security mitigations for better performance.
          WARNING: This reduces security against Spectre/Meltdown attacks.
          Only enable on trusted personal systems.
        '';
      };
    };

    io = {
      enableSchedulerOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable I/O scheduler optimizations";
      };
    };

    desktop = {
      enableCompositorPriority = mkOption {
        type = types.bool;
        default = true;
        description =
          "Boost compositor process priority for smoother animations";
      };

      enableGnomeOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GNOME-specific performance optimizations";
      };
    };

    memory = {
      enableZram = mkOption {
        type = types.bool;
        default = true;
        description = "Enable zram compressed swap in RAM";
      };

      customSwappiness = mkOption {
        type = types.nullOr types.int;
        default = null;
        description =
          "Override swappiness value (0-200). Null uses profile default.";
      };
    };

    thermal = {
      customMinFreqAC = mkOption {
        type = types.nullOr types.int;
        default = null;
        description =
          "Override minimum CPU frequency on AC power (kHz). Null uses profile default.";
      };
    };

    services = {
      disableModemManager = mkOption {
        type = types.bool;
        default = true;
        description = "Disable ModemManager service (no mobile broadband chip)";
      };

      disableNetworkManagerWaitOnline = mkOption {
        type = types.bool;
        default = true;
        description =
          "Disable NetworkManager-wait-online service for faster boot";
      };
    };
  };

  config = mkIf cfg.enable {
    # Kernel sysctl parameter optimizations
    boot.kernel.sysctl = mkIf cfg.kernel.enableSysctlOptimizations {
      # Virtual Memory Management
      "vm.swappiness" = mkDefault (if cfg.memory.customSwappiness != null then
        cfg.memory.customSwappiness
      else
        activeProfile.swappiness);
      "vm.dirty_ratio" = mkDefault 10;
      "vm.dirty_background_ratio" = mkDefault 5;
      "vm.dirty_writeback_centisecs" = mkDefault 1500;
      "vm.dirty_expire_centisecs" = mkDefault 3000;
      "vm.vfs_cache_pressure" = mkDefault 50;
      "vm.compaction_proactiveness" = mkDefault 20;
      "vm.watermark_scale_factor" = mkDefault 125;
      "vm.min_free_kbytes" = mkDefault 131072; # 128MB reserved for critical kernel allocs
      "vm.page-cluster" = mkDefault 0; # Read single pages from zram (faster than default 3-page clusters)

      # Network Stack Optimization
      "net.ipv4.tcp_congestion_control" = mkDefault "bbr";
      "net.core.rmem_max" = mkDefault 16777216;
      "net.core.wmem_max" = mkDefault 16777216;
      "net.core.rmem_default" = mkDefault 1048576;
      "net.core.wmem_default" = mkDefault 1048576;
      "net.ipv4.tcp_rmem" = mkDefault "4096 1048576 16777216";
      "net.ipv4.tcp_wmem" = mkDefault "4096 1048576 16777216";
      "net.ipv4.tcp_fin_timeout" = mkDefault 30;
      "net.ipv4.tcp_tw_reuse" = mkDefault 1;

      # Filesystem and I/O
      # Note: inotify settings are already set by NixOS graphical-desktop module
      "fs.file-max" = mkDefault 2097152;
      "fs.nr_open" = mkDefault 2147483584; # Current kernel maximum (2^31 - 64)

      # Kernel Scheduler Tuning
      "kernel.sched_autogroup_enabled" = mkDefault 1;
    };

    # Boot parameter optimizations
    boot.kernelParams = mkIf cfg.kernel.enableBootOptimizations ([
      "transparent_hugepage=always"
      "nowatchdog" # disables all watchdogs (includes nmi_watchdog)
      "libahci.ignore_sss=1" # Ignore staggered spin-up (faster SSD boot)
      "no_timer_check" # Don't check timers (faster boot)
      # amdgpu.ppfeaturemask set in hardware.nix per-system
    ] ++ optional cfg.kernel.disableMitigations "mitigations=off");

    # Use zstd compression for initrd (faster decompression)
    boot.initrd.compressor = "zstd";

    # I/O Scheduler optimizations
    services.udev.extraRules = mkIf cfg.io.enableSchedulerOptimizations ''
      # NVMe optimization - additional tuning beyond scheduler
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="128"
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="256"
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/rq_affinity}="2"

      # SATA SSD optimization - use mq-deadline scheduler
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/read_ahead_kb}="128"

      # HDD optimization - use bfq scheduler
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/read_ahead_kb}="512"
    '';

    # Zram compressed swap configuration
    zramSwap = mkIf cfg.memory.enableZram {
      enable = mkDefault true;
      algorithm = mkForce "zstd"; # Use zstd for better compression ratio
      memoryPercent = mkForce activeProfile.zramPercent;
      priority = mkForce 10; # Higher priority than default
    };

    # KSM (Kernel Samepage Merging) - deduplicate identical memory pages
    # KSM is controlled via /sys/kernel/mm/ksm/ not sysctl
    systemd.services.ksm-enable = mkIf cfg.kernel.enableSysctlOptimizations {
      description = "Enable Kernel Samepage Merging (KSM) for memory deduplication";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ksm-enable" ''
          # Enable KSM if the kernel supports it (not all do, e.g. VMs without nested virtualization)
          if [ -f /sys/kernel/mm/ksm/run ]; then
            echo 1 > /sys/kernel/mm/ksm/run || true
            echo 256 > /sys/kernel/mm/ksm/max_page_sharing || true
            echo "KSM enabled"
          else
            echo "KSM not available on this kernel, skipping"
          fi
        '';
      };
    };

    # Desktop environment optimizations - compositor priority boosting
    systemd.user.services.compositor-priority =
      mkIf cfg.desktop.enableCompositorPriority {
        description = "Boost compositor process priority for smooth animations";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            "${pkgs.bash}/bin/bash -c 'sleep 2; compositor_pid=$(${pkgs.procps}/bin/pgrep niri || ${pkgs.procps}/bin/pgrep mutter || ${pkgs.procps}/bin/pgrep gnome-shell || ${pkgs.procps}/bin/pgrep kwin_wayland || ${pkgs.procps}/bin/pgrep sway || true); if [ -n \"$compositor_pid\" ]; then ${pkgs.util-linux}/bin/renice -n ${
              toString activeProfile.compositorPriority
            } -p $compositor_pid || true; echo \"Compositor priority boosted to ${
              toString activeProfile.compositorPriority
            }\"; fi'";
        };
      };

    # GNOME-specific performance optimizations
    home-manager.users."${userConfig.user.name}" =
      mkIf cfg.desktop.enableGnomeOptimizations {
        dconf.settings = {
          "org/gnome/mutter" = {
            experimental-features = [ "scale-monitor-framebuffer" ];
            dynamic-workspaces = false;
          };
        };
      };

    # TLP integration - override CPU frequency settings based on profile
    services.tlp.settings = {
      CPU_SCALING_MIN_FREQ_ON_AC = mkForce (if cfg.thermal.customMinFreqAC != null then
        cfg.thermal.customMinFreqAC
      else
        activeProfile.minCpuFreqAC);
      CPU_ENERGY_PERF_POLICY_ON_AC = mkForce activeProfile.cpuEPP;
      CPU_BOOST_ON_AC = mkForce (if activeProfile.enableCpuBoostAC then 1 else 0);
    };

    # Example systemd service resource limits
    # Users can apply these patterns to their own services
    # systemd.services."example-service" = {
    #   serviceConfig = {
    #     MemoryMax = "512M";
    #     MemoryHigh = "384M";
    #   };
    # };

    # Performance monitoring and diagnostic tools
    environment.systemPackages = with pkgs; [ htop iotop stress-ng ];

    # Disable ModemManager (no mobile broadband chip)
    systemd.services.ModemManager.enable =
      mkIf cfg.services.disableModemManager (mkForce false);

    # Disable NetworkManager-wait-online service
    systemd.services.NetworkManager-wait-online.enable =
      mkIf cfg.services.disableNetworkManagerWaitOnline (mkForce false);

    # Enable early OOM killer via systemd.oomd
    systemd.oomd.enable = mkDefault true;

    # EarlyOOM - userspace OOM killer with aggressive thresholds
    # Kills memory hogs before the kernel hard-lockup triggers
    # Note: earlyoom 1.8.2 doesn't support --prefer/--avoid, so it uses default
    # oom_score_adj logic (targets highest-scoring process, usually the memory hog)
    services.earlyoom = {
      enable = mkDefault true;
      freeMemThreshold = mkDefault 2; # SIGTERM at 2% free (default 10%)
      extraArgs = [
        "-M 256000,128000" # SIGTERM at 256MB free, SIGKILL at 128MB free
        "-n" # Desktop notifications via dbus
      ];
    };
  };
}
