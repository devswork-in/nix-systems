{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Faster nix integration with cached evaluations
  };
}
