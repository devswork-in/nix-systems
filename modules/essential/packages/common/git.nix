{ userConfig, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = userConfig.user.name;
      userEmail = userConfig.user.email;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
        rebase = {
          autoStash = true;
        };
        credential = {
          helper = "store";
        };
      };
      # ref:
      # delete ~/.gitconfig if already exists, it will conflict with the changes
      # https://discourse.nixos.org/t/is-it-possible-to-change-the-default-git-user-config-for-a-devshell/17612/3
      # https://github.com/NobbZ/nixos-config/blob/8848aa0cc4d65d7960ec2c8535e33d212e6691d2/home/modules/profiles/development/default.nix#L70-L76
      #includes = [
      #  {
      #    condition = "gitdir:~/Work/<company-name>/**";
      #    contents = {
      #      init.defaultBranch = "master";
      #      user.name = "";
      #      user.email = "";
      #    };
      #  }
      #];
    };
    lazygit.enable = true;
  };
}
