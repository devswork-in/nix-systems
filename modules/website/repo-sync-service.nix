{ pkgs, ... }:

let
  config = (import ./../../config.nix { });
  syncRepos = config.syncRepos;

  generateRepoSyncScript = pkgs.writeShellScript "repo-sync.sh" ''
    LOG_FILE="/var/log/repo-sync.log"
    mkdir -p /var/log
    touch $LOG_FILE
    chmod 666 $LOG_FILE

    while true; do
      echo "Running repo-sync at $(date)" >> $LOG_FILE

      repos='${builtins.toJSON syncRepos}'
      echo $repos | ${pkgs.jq}/bin/jq -c '.[]' | while read -r repo; do
        url=$(echo $repo | ${pkgs.jq}/bin/jq -r .url)
        localPath=$(echo $repo | ${pkgs.jq}/bin/jq -r .localPath)
        echo "Processing repo $url to $localPath" >> $LOG_FILE
        mkdir -p $(dirname $localPath)
        export HOME=$(mktemp -d)
        ${pkgs.git}/bin/git config --global --add safe.directory $localPath
        if [ ! -d "$localPath/.git" ]; then
          echo "Cloning $url to $localPath" >> $LOG_FILE
          ${pkgs.git}/bin/git clone $url $localPath && \
          echo "Cloning $url complete!" >> $LOG_FILE || \
          echo "Cloning $url failed with exit code $?" >> $LOG_FILE
          chown -R ${config.userName}:users $localPath
        else
          echo "Directory $localPath already exists, pulling latest changes." >> $LOG_FILE
          cd $localPath && \
          ${pkgs.git}/bin/git pull && \
          echo "Update complete!" >> $LOG_FILE || \
          echo "Update failed with exit code $?" >> $LOG_FILE
        fi
      done

      sleep 10
    done
  '';
in
{
  systemd.services.repo-sync = {
    enable = true; # keep service enabled after reboot
    description = "Sync Repository Service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${generateRepoSyncScript}";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "multi-user.target" ]; # specify the target to start the service
  };
}
