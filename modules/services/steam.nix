{ pkgs, userConfig, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;

      # Override the Steam package to fix missing steamclient.so without polluting
      # the global environment (which breaks apps like Zen Browser)
      package = pkgs.steam.override {
        extraProfile = ''
          export LD_LIBRARY_PATH=$HOME/.local/share/Steam/ubuntu12_32:$HOME/.local/share/Steam/ubuntu12_64:$LD_LIBRARY_PATH
        '';
      };

      # Ensure Steam and games install to /home (default behavior)
      # Steam library: ~/.local/share/Steam/steamapps
      # Shader cache: ~/.local/share/Steam/steamapps/shadercache

      # Add Proton-GE for better game compatibility
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

      # Auto-enable Steam Play (Proton) for all titles
      # This eliminates the need to manually enable it in Steam settings
      localNetworkGameTransfers.openFirewall = true;
    };

    gamemode = {
      enable = true;
      enableRenice = true; # Allow games to increase priority
      settings = {
        general = {
          renice = 10;
          # Increase process priority for games
          ioprio = 0;
        };
        gpu = {
          # Set AMD GPU to high performance during gaming
          apply_gpu_optimisations = "accept-responsibility";
          amd_performance_level = "high";
          gpu_device = 0;
        };
        cpu = {
          # Pin games to performance cores (if available)
          park_cores = "no";
          pin_cores = "yes";
        };
        custom = {
          # Set CPU EPP to performance mode for gaming (amd-pstate-epp driver)
          start =
            "${pkgs.bash}/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; ${pkgs.libnotify}/bin/notify-send \"GameMode\" \"Performance mode activated\"'";
          end =
            "${pkgs.bash}/bin/bash -c 'echo balance_performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; ${pkgs.libnotify}/bin/notify-send \"GameMode\" \"Performance mode deactivated\"'";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Performance monitoring
    mangohud

    # Performance tools
    gamemode
    gamescope

    # Useful gaming utilities
    steam-run # Run non-Steam games with Steam runtime
  ];

  environment.sessionVariables = {
    # Steam Proton-GE compatibility tools path
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";

    # AMD GPU optimizations for gaming
    AMD_VULKAN_ICD = "RADV"; # Use RADV (better performance)
    RADV_PERFTEST = "gpl,nggc"; # Enable GPL shader compiler and NGG culling

    # Ensure games use /home for shader cache
    __GL_SHADER_DISK_CACHE_PATH = "\${HOME}/.cache/mesa_shader_cache";

    # Wine/Proton optimizations
    WINEFSYNC = "1"; # Enable fsync for better performance
    WINE_CPU_TOPOLOGY = "8:8"; # Match your CPU topology (8 cores)

    # DXVK optimizations (DirectX to Vulkan)
    DXVK_HUD = "compiler"; # Show shader compilation
    DXVK_STATE_CACHE_PATH = "\${HOME}/.cache/dxvk_state_cache";
  };

  # Allow users to use realtime priority (needed for some games)
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@users";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@users";
      item = "nice";
      type = "-";
      value = "-11";
    }
  ];

  # Note: Manual CPU governor changes are NOT needed on NixOS
  # GameMode automatically handles performance optimization when games launch
  # TLP manages power when not gaming, GameMode overrides it during gaming

  # Auto-create gaming directories in /home on boot (survives reinstalls if /home is preserved)
  systemd.tmpfiles.rules = [
    # Shader cache directories (auto-created in /home)
    "d /home/${userConfig.user.name}/.cache/mesa_shader_cache 0755 ${userConfig.user.name} users -"

    # Steam directories (auto-created in /home)
    "d /home/${userConfig.user.name}/.local/share/Steam 0755 ${userConfig.user.name} users -"
    "d /home/${userConfig.user.name}/.steam 0755 ${userConfig.user.name} users -"
    "d /home/${userConfig.user.name}/.steam/root/compatibilitytools.d 0755 ${userConfig.user.name} users -"

    # MangoHud config directory with default config (auto-created in /home)
    "d /home/${userConfig.user.name}/.config/MangoHud 0755 ${userConfig.user.name} users -"
  ];

  # Create default MangoHud configuration
  environment.etc."skel/.config/MangoHud/MangoHud.conf".text = ''
    # MangoHud Configuration - Auto-generated
    # Toggle with Shift+F12 in games

    # Performance metrics
    fps
    frametime
    frame_timing=1

    # GPU info
    gpu_stats
    gpu_temp
    gpu_core_clock
    gpu_mem_clock
    gpu_power
    vram

    # CPU info
    cpu_stats
    cpu_temp
    cpu_power

    # RAM
    ram

    # Position and appearance
    position=top-left
    font_size=24
    background_alpha=0.5

    # FPS limit (0 = unlimited)
    fps_limit=0

    # Logging (toggle with Shift+F2)
    output_folder=/home/${userConfig.user.name}/Documents/mangohud_logs
  '';

  # Firewall rules for gaming
  networking.firewall = {
    # Steam Remote Play, game streaming
    allowedTCPPortRanges = [
      {
        from = 27015;
        to = 27030;
      } # Steam game servers
      {
        from = 27036;
        to = 27037;
      } # Steam Remote Play
    ];
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27031;
      } # Steam game traffic
      {
        from = 27036;
        to = 27037;
      } # Steam Remote Play
    ];
  };
}
