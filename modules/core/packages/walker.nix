# Walker launcher module - using official walker flake NixOS module
# Requires: walker + elephant flake inputs in flake.nix
{ inputs, ... }:

{
  imports = [ inputs.walker.nixosModules.default ];

  programs.walker = {
    enable = true;

    config = {
      providers.default = [
        "desktopapplications"
        "clipboard"
        "files"
        "calc"
        "symbols"
        "websearch"
        "runner"
        "windows"
        "todo"
        "bookmarks"
        "niriactions"
      ];

      keybinds = {
        close = ["Escape"];
        next = ["Down"];
        previous = ["Up"];
        left = ["Left"];
        right = ["Right"];
        toggle_exact = ["ctrl e"];
        resume_last_query = ["ctrl r"];
        quick_activate = ["F1" "F2" "F3" "F4"];
        page_down = ["Page_Down"];
        page_up = ["Page_Up"];
        show_actions = ["alt j"];
      };
    };

    elephant = {
      providers = [
        "desktopapplications"
        "files"
        "clipboard"
        "calc"
        "symbols"
        "websearch"
        "runner"
        "windows"
        "todo"
        "bookmarks"
        "niriactions"
      ];
    };
  };
}
