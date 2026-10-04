# Walker launcher module - using official walker flake NixOS module
# Requires: walker + elephant flake inputs in flake.nix
{ inputs, ... }:

{
  disabledModules = [ "services/misc/elephant.nix" ]; # Walker still imports its own Elephant module.
  imports = [ inputs.walker.nixosModules.default ];




  programs.walker = {
    themes.gruvbox.style = builtins.readFile ../../desktops/wayland/common/walker/style.css;
    themes.gruvbox.layouts.layout = builtins.replaceStrings
      [
        ''<property name="width-request">600</property>''
        ''<property name="height-request">570</property>''
        ''<property name="max-content-height">400</property>''
        ''<property name="spacing">10</property>''
        ''<object class="GtkEntry" id="Input">''
      ]
      [
        ''<property name="width-request">736</property>''
        ''<property name="height-request">336</property>''
        ''<property name="max-content-height">260</property>''
        ''<property name="spacing">0</property>''
        ''<object class="GtkEntry" id="Input">
            <property name="primary-icon-name">system-search-symbolic</property>
            <property name="primary-icon-activatable">false</property>''
      ]
      (builtins.readFile "${inputs.walker}/resources/themes/default/layout.xml");
    themes.gruvbox.layouts.item_desktopapplications = builtins.replaceStrings
      [ ''<property name="orientation">vertical</property>''
        ''<property name="spacing">0</property>'' ]
      [ ''<property name="orientation">horizontal</property>''
        ''<property name="spacing">6</property>'' ]
      (builtins.readFile "${inputs.walker}/resources/themes/default/item.xml");
    config.theme = "gruvbox";


    enable = true;

    config = {
      hide_action_hints = true;
      hide_quick_activation = true;
      placeholders.default.input = "Search...";
      placeholders.default.list = "No Results";
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
