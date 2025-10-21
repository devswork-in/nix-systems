# Server-specific environment variables
{ lib, ... }:

{
  # Server-specific environment variables
  home.sessionVariables = {
    # Keep tmux auto-start enabled on servers (don't set TMUX_DISABLE_AUTO_START)
    # Add other server-specific environment variables here
    XDG_SESSION_TYPE = "tty";
  };
  
  # Extend PATH for user-specific tools and package managers
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin" 
    "$HOME/.bun/bin"
    # Python user packages (scripts) go to $HOME/.local/bin by default
  ];
}