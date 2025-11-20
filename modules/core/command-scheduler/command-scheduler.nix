# Command Scheduler Module
# Generates systemd services and timers from scheduled-commands.nix configuration
{ config, pkgs, lib, userConfig, ... }:

let
  user = userConfig.user.name;
  homeDir = "/home/${user}";
  configPath = "${homeDir}/.config/scheduled-scripts/scheduled-commands.nix";
  
  # Import scheduled commands from synced location (fallback to repo if not synced yet)
  scheduledCommandsConfig = 
    if builtins.pathExists configPath
    then import configPath { inherit config pkgs lib userConfig; }
    else import ../../../scheduled-scripts/scheduled-commands.nix { inherit config pkgs lib userConfig; };
  
  # Determine system type by checking if Xserver is enabled
  isDesktop = config.services.xserver.enable;
  isServer = !isDesktop;
  
  # Select appropriate commands based on system type
  activeCommands = 
    (scheduledCommandsConfig.common or []) ++
    (if isDesktop then (scheduledCommandsConfig.desktop or []) else []) ++
    (if isServer then (scheduledCommandsConfig.server or []) else []);
  
  # Filter enabled commands
  enabledCommands = builtins.filter (cmd: cmd.enabled or true) activeCommands;
  
  # Separate by execution level
  userCommands = builtins.filter (cmd: (cmd.level or "user") == "user") enabledCommands;
  systemCommands = builtins.filter (cmd: (cmd.level or "user") == "system") enabledCommands;
  
  # Expand ~ in paths
  expandPath = path: 
    if path == "~" then homeDir
    else if lib.hasPrefix "~/" path 
    then "${homeDir}/${lib.removePrefix "~/" path}"
    else path;
  
  # Generate wrapper script with comprehensive logging
  mkCommandWrapper = { name, command ? null, script ? null, workingDirectory, environment, level }:
    let
      actualCommand = if script != null then "${script}" else command;
      executingUser = if level == "system" then "root" else user;
      expandedWorkDir = expandPath workingDirectory;
    in
    pkgs.writeShellScript "scheduled-${name}" ''
      # Logging setup
      LOG_PREFIX="[SCHEDULED-COMMAND]"
      START_TIME=$(date -Iseconds)
      START_EPOCH=$(date +%s)
      
      echo "$LOG_PREFIX START: $START_TIME"
      echo "$LOG_PREFIX NAME: ${name}"
      echo "$LOG_PREFIX USER: ${executingUser}"
      echo "$LOG_PREFIX LEVEL: ${level}"
      echo "$LOG_PREFIX WORKING_DIR: ${expandedWorkDir}"
      echo "$LOG_PREFIX COMMAND: ${actualCommand}"
      
      # Set environment variables
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}='${expandPath v}'") environment)}
      
      # Execute command and capture output
      cd "${expandedWorkDir}" || exit 1
      set +e
      OUTPUT=$(${actualCommand} 2>&1)
      EXIT_CODE=$?
      set -e
      
      END_TIME=$(date -Iseconds)
      END_EPOCH=$(date +%s)
      DURATION=$((END_EPOCH - START_EPOCH))
      
      echo "$LOG_PREFIX OUTPUT: $OUTPUT"
      echo "$LOG_PREFIX EXIT_CODE: $EXIT_CODE"
      echo "$LOG_PREFIX END: $END_TIME"
      echo "$LOG_PREFIX DURATION: ''${DURATION}s"
      
      exit $EXIT_CODE
    '';
  
  # Generate systemd service
  mkService = { name, description, wrapper }:
    {
      Unit = {
        Description = description;
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${wrapper}";
      };
    };
  
  # Generate systemd timer
  mkTimer = { name, description, schedule }:
    let
      # Capitalize timer keys for systemd
      capitalizeKey = key:
        if key == "onCalendar" then "OnCalendar"
        else if key == "onBootSec" then "OnBootSec"
        else if key == "onUnitActiveSec" then "OnUnitActiveSec"
        else if key == "onActiveSec" then "OnActiveSec"
        else key;
      
      timerConfig = lib.mapAttrs' (k: v: lib.nameValuePair (capitalizeKey k) v) schedule // {
        Persistent = true;  # Run missed timers on boot
      };
    in
    {
      Unit = {
        Description = "Timer for ${description}";
      };
      Timer = timerConfig;
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  # Hot-reload script that triggers nixos-rebuild when config changes
  reloadScript = pkgs.writeShellScript "reload-scheduled-commands" ''
    echo "[SCHEDULED-COMMANDS-RELOAD] Config change detected at $(date -Iseconds)"
    echo "[SCHEDULED-COMMANDS-RELOAD] Triggering nixos-rebuild switch..."
    
    # Run nixos-rebuild switch in background
    sudo nixos-rebuild switch &
    
    echo "[SCHEDULED-COMMANDS-RELOAD] Rebuild triggered (running in background)"
  '';
in
{
  # Allow user to run nixos-rebuild without password for hot-reload
  security.sudo.extraRules = [
    {
      users = [ user ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # Hot-reload: Watch config file and trigger rebuild on changes
  home-manager.users."${user}" = { ... }: {
    # Path unit that watches the config file
    systemd.user.paths.scheduled-commands-watcher = {
      Unit = {
        Description = "Watch scheduled-commands.nix for changes";
      };
      Path = {
        PathModified = "${homeDir}/.config/scheduled-scripts/scheduled-commands.nix";
        Unit = "scheduled-commands-reload.service";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    # Generate user-level services and timers
    systemd.user.services = lib.listToAttrs (
      # Reload service
      [ (lib.nameValuePair "scheduled-commands-reload" {
          Unit = {
            Description = "Reload scheduled commands configuration";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${reloadScript}";
          };
        })
      ] ++
      # Scheduled command services
      (map (cmd:
        let
          wrapper = mkCommandWrapper {
            inherit (cmd) name environment;
            command = cmd.command or null;
            script = cmd.script or null;
            workingDirectory = cmd.workingDirectory or "~";
            level = "user";
          };
        in
        lib.nameValuePair "scheduled-${cmd.name}" (mkService {
          inherit (cmd) name description;
          inherit wrapper;
        })
      ) userCommands)
    );
    
    systemd.user.timers = lib.listToAttrs (map (cmd:
      lib.nameValuePair "scheduled-${cmd.name}" (mkTimer {
        inherit (cmd) name description schedule;
      })
    ) userCommands);
  };
  
  # Generate system-level services and timers
  systemd.services = lib.listToAttrs (map (cmd:
    let
      wrapper = mkCommandWrapper {
        inherit (cmd) name environment;
        command = cmd.command or null;
        script = cmd.script or null;
        workingDirectory = cmd.workingDirectory or "/root";
        level = "system";
      };
    in
    lib.nameValuePair "scheduled-${cmd.name}" (mkService {
      inherit (cmd) name description;
      inherit wrapper;
    })
  ) systemCommands);
  
  systemd.timers = lib.listToAttrs (map (cmd:
    lib.nameValuePair "scheduled-${cmd.name}" (mkTimer {
      inherit (cmd) name description schedule;
    })
  ) systemCommands);
}
