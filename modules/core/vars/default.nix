{ pkgs, config, userConfig, ... }: {
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "bat";
    BROWSER = "zen-browser";
    TERMINAL = "kitty";
    READER = "zathura";

    # System Identity Variables
    NIX_CONFIG_DIR = "/etc/nixos";
    NIX_SYSTEM = config.networking.hostName;
  };

  # Activation script to ensure env vars are synced even if nix-repo-sync fails
  # This guarantees the .sh files exist for shell startup
  system.activationScripts.syncEnvVars = {
    text = ''
      echo "Syncing environment variables..."
      mkdir -p /home/${userConfig.user.name}/.config/env

      # Symlink common vars
      if [ "${config.networking.hostName}" = "phoenix" ] || [ "${config.networking.hostName}" = "server" ] || [ "${config.networking.hostName}" = "blade" ]; then
        ln -sf ${./common.sh} /home/${userConfig.user.name}/.config/env/common.sh
      else
        ln -sf /etc/nixos/modules/core/vars/common.sh /home/${userConfig.user.name}/.config/env/common.sh
      fi

      # Symlink system-specific vars
      if [ "${config.networking.hostName}" = "phoenix" ] || [ "${config.networking.hostName}" = "server" ] || [ "${config.networking.hostName}" = "blade" ]; then
         # For Servers, verify existence in source tree (nix store)
         if [ -f ${./.}/${config.networking.hostName}.sh ]; then
           ln -sf ${./.}/${config.networking.hostName}.sh /home/${userConfig.user.name}/.config/env/${config.networking.hostName}.sh
         fi
      else
         ln -sf /etc/nixos/modules/core/vars/${config.networking.hostName}.sh /home/${userConfig.user.name}/.config/env/${config.networking.hostName}.sh || true
      fi

      # Symlink desktop/server vars based on profile
      if [ "${config.networking.hostName}" = "phoenix" ] || [ "${config.networking.hostName}" = "server" ] || [ "${config.networking.hostName}" = "blade" ]; then
          if [ -f ${./desktop.sh} ]; then
              ln -sf ${./desktop.sh} /home/${userConfig.user.name}/.config/env/desktop.sh
          fi
          if [ -f ${./server.sh} ]; then
              ln -sf ${./server.sh} /home/${userConfig.user.name}/.config/env/server.sh
          fi
      else
          if [ -f /etc/nixos/modules/core/vars/desktop.sh ]; then
              ln -sf /etc/nixos/modules/core/vars/desktop.sh /home/${userConfig.user.name}/.config/env/desktop.sh
          fi
          if [ -f /etc/nixos/modules/core/vars/server.sh ]; then
              ln -sf /etc/nixos/modules/core/vars/server.sh /home/${userConfig.user.name}/.config/env/server.sh
          fi
      fi

      chown -R ${userConfig.user.name}:users /home/${userConfig.user.name}/.config/env
    '';
    deps = [ ];
  };
}
