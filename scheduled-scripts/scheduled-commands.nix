{ config, pkgs, lib, userConfig, ... }:

{
  # Commands that run on ALL systems (desktop and server)
  common = [
    # Example: Uncomment to enable
    # {
    #   name = "disk-space-check";
    #   description = "Check disk space usage";
    #   command = "${pkgs.coreutils}/bin/df -h";
    #   schedule = { onCalendar = "hourly"; };
    #   level = "user";
    #   enabled = true;
    # }
  ];

  # Commands that ONLY run on DESKTOP systems
  desktop = [
    {
      name = "ensure-screenshots-dir";
      description = "Ensure Screenshots directory exists";
      command = "${pkgs.coreutils}/bin/mkdir -p ${userConfig.desktop.screenshotsPath or "~/Screenshots"}";
      schedule = {
        onBootSec = "1min";
        onUnitActiveSec = "1min";
      };
      level = "user";
      enabled = true;
      workingDirectory = "~";
      environment = {};
    }
    {
      name = "cleanup-old-screenshots";
      description = "Delete screenshots older than 30 days";
      script = ./scripts/cleanup-screenshots.sh;
      schedule = {
        onCalendar = "daily";
      };
      level = "user";
      enabled = true;
      workingDirectory = "~";
      environment = {
        SCREENSHOTS_DIR = userConfig.desktop.screenshotsPath or "~/Screenshots";
        RETENTION_DAYS = "30";
      };
    }

  ];

  # Commands that ONLY run on SERVER systems
  server = [
    # Example: Uncomment to enable
    # {
    #   name = "backup-configs";
    #   description = "Backup system configuration files";
    #   script = ./scripts/backup-configs.sh;
    #   schedule = { onCalendar = "Mon,Wed,Fri 02:00"; };
    #   level = "system";
    #   enabled = true;
    #   environment = {
    #     BACKUP_DIR = "/var/backups/configs";
    #     RETENTION_DAYS = "90";
    #   };
    # }
  ];
}
