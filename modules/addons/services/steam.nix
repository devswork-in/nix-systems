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
    gamemode.enable = true;
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
