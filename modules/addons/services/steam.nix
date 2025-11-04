{ pkgs, ... }:

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
    };
    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = {
          # Set AMD GPU to high performance during gaming
          # Note: This requires apply_gpu_optimisations due to gamemode bug #522
          # However, amd_performance_level is NOT overclocking - it's standard power management
          apply_gpu_optimisations = "accept-responsibility";
          amd_performance_level = "high";
          gpu_device = 0;
        };
        custom = {
          # Optional: Add custom scripts to run on game start/end
          # start = "${pkgs.libnotify}/bin/notify-send 'GameMode activated'";
          # end = "${pkgs.libnotify}/bin/notify-send 'GameMode deactivated'";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    bottles
    lutris
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
