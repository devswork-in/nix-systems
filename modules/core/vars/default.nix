{ pkgs, ... }: {
  environment.variables = {
    PAGER = "bat";
    BROWSER = "zen-browser";
    TERMINAL = "kitty";
    READER = "zathura";
  };
}
