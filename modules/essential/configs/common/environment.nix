# Generic environment variables for all systems
{ ... }:

{
  # Common environment variables for all systems
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "bat";
    BROWSER = "google-chrome";
    TERMINAL = "kitty";
    READER = "zathura";
  };
}