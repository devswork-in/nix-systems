{ ... }:
let
  userName = (import ./../config.nix {}).userName;
in
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users."${userName}".extraGroups = ["docker"];
}
