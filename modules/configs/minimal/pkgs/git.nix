{
  config,
  pkgs,
  lib,
  ...
}:
let
  config = (import ./../../../../config.nix { });
in
{
  programs = {
    git = {
      enable = true;
      userName = "${config.userName}";
      userEmail = "${config.userEmail}";
      extraConfig = {
        pull.rebase = true;
      };
      # ref:
      # delete ~/.gitconfig if already exists, it will conflict with the changes
      # https://discourse.nixos.org/t/is-it-possible-to-change-the-default-git-user-config-for-a-devshell/17612/3
      # https://github.com/NobbZ/nixos-config/blob/8848aa0cc4d65d7960ec2c8535e33d212e6691d2/home/modules/profiles/development/default.nix#L70-L76
      includes = [
        {
          condition = "gitdir:~/Work/**";
          contents = {
            init.defaultBranch = "master";
            user.name = "Saroj Kumar Mahato";
            user.email = "sarojkumar@criodo.com";
          };
        }
      ];
    };
    lazygit.enable = true;
  };
}
