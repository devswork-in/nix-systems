{ user, paths, nixSystemsPath ? "/home/${user.name}/nix-systems" }:

let
  # Use the provided nix-systems path or default to home directory
  nixSystemsRoot = nixSystemsPath;
in
{
  # Common sync items for ALL systems (desktop and server)
  # These will be synced on every system
  common = [
    # Neovim config from GitHub (one-way sync)
    {
      type = "git";
      url = "https://github.com/creator54/starter";
      dest = "~/.config/nvim";
    }
    
    # Local nix-systems configs (bi-directional via symlinks)
    # These symlinks allow editing files in either location
    # Using relative paths from nix-systems root
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/aliases";
      dest = "~/.config/aliases";
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
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/essential/configs/common/scripts";
      dest = "~/.local/bin";
    }
  ];

  # Server-specific sync items
  # Only synced on server systems
  server = [
    {
      type = "git";
      url = "https://github.com/creator54/creator54.me";
      dest = "${paths.base}/${user.domain}";
    }
    {
      type = "git";
      url = "https://github.com/creator54/blog.creator54.me";
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
      source = "${nixSystemsRoot}/modules/addons/desktop/clipit/clipitrc";
      dest = "~/.config/clipit/clipitrc";
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
