{ config, lib, pkgs, userConfig, options, ... }:

let
  isWayland = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "wayland"
    || (lib.attrByPath ["programs" "niri" "enable"] false config)
    || (lib.attrByPath ["programs" "hyprland" "enable"] false config)
    || (lib.attrByPath ["programs" "sway" "enable"] false config);

  isX11 = (lib.attrByPath ["sessionManager" "sessionType"] "" config) == "x11"
    || (lib.attrByPath ["services" "xserver" "windowManager" "dwm" "enable"] false config)
    || (lib.attrByPath ["services" "xserver" "windowManager" "i3" "enable"] false config);
in
{
  options.desktop.lockscreen = {
    enable = lib.mkEnableOption "Desktop Lockscreen Manager";
    autoLock = lib.mkEnableOption "Auto-lock session on idle";
  };

  config = lib.mkIf config.desktop.lockscreen.enable (lib.mkMerge [
    
    # Enable Hyprlock for Wayland (Only if option exists)
    (lib.optionalAttrs (options ? wayland && options.wayland ? hyprlock) {
      wayland.hyprlock = lib.mkIf isWayland {
        enable = true;
        autoLock = config.desktop.lockscreen.autoLock;
      };
    })

    # Common Configuration
    {
      # Install Slock for X11 and Unified lock script
      environment.systemPackages = (lib.optionals isX11 [ pkgs.slock ]) ++ [
        (pkgs.writeShellScriptBin "lock-session" ''
          if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
            ${pkgs.hyprlock}/bin/hyprlock
          else
            ${pkgs.slock}/bin/slock
          fi
        '')
      ];

      # X11 Auto-locking via screen-locker (uses xss-lock/xautolock)
      home-manager.users."${userConfig.user.name}" = { ... }: {
        services.screen-locker = lib.mkIf (isX11 && config.desktop.lockscreen.autoLock) {
          enable = true;
          lockCmd = "${pkgs.slock}/bin/slock";
          inactiveInterval = 10; # 10 minutes
        };
      };
    }
  ]);
}
