{ ... }:
let
  config = (import ./../../../config.nix {});
  user = config.userName;
  stateVersion = config.nixosReleaseVersion;
in 
{
  home-manager = {
    users."${user}" = { ... }: {
      imports = [
        ./pkgs
        ./symlinks
      ];

      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "${stateVersion}";
      };
    };

    # Remove backup extension and add overwrite setting
    extraSpecialArgs = {
      home.file.allowOverwrite = true;
    };
  };
}
