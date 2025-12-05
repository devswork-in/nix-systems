# Generic environment variables for all systems
{ config, ... }:

{
  # Common environment variables for all systems
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Extend PATH for user-specific tools and package managers
  home.sessionPath = [
    # Use the home directory defined in home-manager config for each user
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.bun/bin"
    # Python user packages (scripts) go to $HOME/.local/bin by default
  ];
}