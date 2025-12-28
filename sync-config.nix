{ user, paths, flakeRoot }:
# Sync configuration for nix-repo-sync
# See nix-repo-sync/README.md for usage details

let nixSystemsRoot = flakeRoot;
in {
  # Synced on all systems
  common = [
    {
      type = "git";
      source = "https://github.com/creator54/starter";
      dest = "~/.config/nvim";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/aliases";
      dest = "~/.config/aliases";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/scripts";
      dest = "~/.local/bin";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/scheduled-scripts";
      dest = "~/.config/scheduled-scripts";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/htop/htoprc";
      dest = "~/.config/htop/htoprc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/tmux.conf";
      dest = "~/.tmux.conf";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/bashrc";
      dest = "~/.bashrc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/fish";
      dest = "~/.config/fish";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/npmrc";
      dest = "~/.npmrc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/vars/common.sh";
      dest = "~/.config/env/common.sh";
    }
  ];

  # Server-specific sync items
  # Only synced on server systems
  server = [
    {
      type = "git";
      source = "https://github.com/creator54/creator54.me";
      dest = "${paths.base}/${user.domain}";
    }
    {
      type = "git";
      source = "https://github.com/creator54/blog.creator54.me";
      dest = "${paths.base}/blog.${user.domain}";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/vars/server.sh";
      dest = "~/.config/env/server.sh";
    }
  ];

  # Desktop-specific sync items (optional)
  # Only synced on desktop systems
  desktop = [
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/kitty.conf";
      dest = "~/.config/kitty/kitty.conf";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/gromit-mpx.ini";
      dest = "~/.config/gromit-mpx.ini";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktop-utils/flameshot/flameshot.ini";
      dest = "~/.config/flameshot/flameshot.ini";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/xinitrc";
      dest = "~/.xinitrc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/Xresources";
      dest = "~/.Xresources";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/addon-aliases";
      dest = "~/.config/addon-aliases";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/xplr";
      dest = "~/.config/xplr";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/mpv";
      dest = "~/.config/mpv";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/icons";
      dest = "~/.icons";
    }

    # Niri Wayland compositor configuration
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/config.kdl";
      dest = "~/.config/niri/config.kdl";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/niri/waybar-config.json";
      dest = "~/.config/waybar/config";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/niri/waybar-style.css";
      dest = "~/.config/waybar/style.css";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/swappy-config";
      dest = "~/.config/swappy/config";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/vars/desktop.sh";
      dest = "~/.config/env/desktop.sh";
    }
  ];

  # Omnix-specific sync items
  omnix = [{
    type = "local";
    source = "${nixSystemsRoot}/modules/core/vars/omnix.sh";
    dest = "~/.config/env/omnix.sh";
  }];

  # DWM-specific sync items (Imported by DWM module)
  dwm = [
    {
      type = "git";
      source = "https://github.com/Creator54/dwm.git";
      dest = "~/.config/dwm";
    }
    {
      type = "git";
      source = "https://github.com/Creator54/dwmblocks.git";
      dest = "~/.config/dwmblocks";
    }
  ];
}
