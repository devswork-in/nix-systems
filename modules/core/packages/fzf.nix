{ ... }:

{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true; # Auto-binds Ctrl+R, Ctrl+T, Alt+C
    enableBashIntegration = true;
  };
}
