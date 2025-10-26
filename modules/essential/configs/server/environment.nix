# Server-specific environment variables
{ lib, ... }:

{
  # Server-specific environment variables
  home.sessionVariables = {
    # Keep tmux auto-start enabled on servers (don't set TMUX_DISABLE_AUTO_START)
    # Add other server-specific environment variables here
    XDG_SESSION_TYPE = "tty";
  };
}