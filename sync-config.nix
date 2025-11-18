{ user, paths, flakeRoot }:
# Sync configuration for nix-repo-sync
# See nix-repo-sync/README.md for usage details

let
  nixSystemsRoot = flakeRoot;
in
{
  # Synced on all systems
  common = [
    {
      type = "git";
      source = "https://github.com/creator54/starter";
      dest = "~/.config/nvim";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/aliases";
      dest = "~/.config/aliases";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/scheduled-scripts";
      dest = "~/.config/scheduled-scripts";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/htop/htoprc";
      dest = "~/.config/htop/htoprc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/tmux.conf";
      dest = "~/.tmux.conf";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/bashrc";
      dest = "~/.bashrc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/fish";
      dest = "~/.config/fish";
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
  ];

  # Desktop-specific sync items (optional)
  # Only synced on desktop systems
  desktop = [
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/kitty.conf";
      dest = "~/.config/kitty/kitty.conf";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/gromit-mpx.ini";
      dest = "~/.config/gromit-mpx.ini";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/flameshot/flameshot.ini";
      dest = "~/.config/flameshot/flameshot.ini";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/xinitrc";
      dest = "~/.xinitrc";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/Xresources";
      dest = "~/.Xresources";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/addon-aliases";
      dest = "~/.config/addon-aliases";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/xplr";
      dest = "~/.config/xplr";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/mpv";
      dest = "~/.config/mpv";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/addons/desktop/icons";
      dest = "~/.icons";
    }
  ];
}
