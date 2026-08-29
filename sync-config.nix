{ user, paths, flakeRoot ? null, pkgs ? null, ... }:
# Sync configuration for nix-repo-sync
# See nix-repo-sync/README.md for usage details

let nixSystemsRoot = if flakeRoot != null then flakeRoot else "./.";
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
      source = "${nixSystemsRoot}/modules/core/configs/common/fish/config.fish";
      dest = "~/.config/fish/config.fish";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/fish/functions";
      dest = "~/.config/fish/functions";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/fish/completions";
      dest = "~/.config/fish/completions";
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
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/gitconfig";
      dest = "~/.gitconfig";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/starship.toml";
      dest = "~/.config/starship.toml";
    }
    {
      type = "git";
      source = "https://github.com/eduwass/tmux-palette";
      dest = "~/.config/tmux/tmux-palette";
      postSync = if pkgs != null then
        "cd ~/.config/tmux/tmux-palette && ${pkgs.bun}/bin/bun install --silent"
      else
        "cd ~/.config/tmux/tmux-palette && bun install --silent";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/configs/common/tmux-palette";
      dest = "~/.config/tmux-palette";
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
      source = "https://github.com/creator54/blogger";
      dest = "${paths.base}/blog.${user.domain}";
      # Build the site after sync
      postSync = if pkgs != null then
        "${pkgs.nix}/bin/nix-shell -I nixpkgs=${pkgs.path} -p pnpm nodejs_22 --run 'pnpm install && pnpm run build'"
      else
        "nix-shell -p pnpm nodejs_22 --run 'pnpm install && pnpm run build'";
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
      source = "${nixSystemsRoot}/modules/desktop-utils/gtk/gtkrc-2.0";
      dest = "~/.gtkrc-2.0";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/gtk/settings.ini";
      dest = "~/.config/gtk-3.0/settings.ini";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/gtk/settings.ini";
      dest = "~/.config/gtk-4.0/settings.ini";
    }
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
      source = "${nixSystemsRoot}/modules/desktop-utils/mpv/youtube-quality.conf";
      dest = "~/.config/mpv/youtube-quality.conf";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/mpv/scripts";
      dest = "~/.config/mpv/scripts";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktop-utils/icons";
      dest = "~/.icons";
    }

    {
      type = "local";
      source = "${nixSystemsRoot}/modules/core/vars/desktop.sh";
      dest = "~/.config/env/desktop.sh";
    }
  ];

  # Niri-specific sync items
  # Only synced when programs.niri.enable is true
  niri = [
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/swayosd.css";
      dest = "~/.config/swayosd/style.css";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/config.kdl";
      dest = "~/.config/niri/config.kdl";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/night-light.frag";
      dest = "~/.config/niri/night-light.frag";
    }
    {
      type = "local";
      source = "${nixSystemsRoot}/modules/desktops/wayland/niri/niri-sidebar/config.toml";
      dest = "~/.config/niri-sidebar/config.toml";
    }
    # Shared Wayland component configs
    # swaylock config
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/swaylock.conf";
      dest = "~/.config/swaylock/config";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/waybar/config.json";
      dest = "~/.config/waybar/config";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/waybar/style.css";
      dest = "~/.config/waybar/style.css";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/waybar/scripts/battery_monitor.py";
      dest = "~/.config/waybar/battery_monitor.py";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/waybar/scripts/memory_monitor.py";
      dest = "~/.config/waybar/memory_monitor.py";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/waybar/scripts/disk_monitor.py";
      dest = "~/.config/waybar/disk_monitor.py";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/swaync/config.json";
      dest = "~/.config/swaync/config.json";
    }
    {
      type = "local";
      source =
        "${nixSystemsRoot}/modules/desktops/wayland/common/swaync/style.css";
      dest = "~/.config/swaync/style.css";
    }
  ];

  # Omnix-specific sync items
  omnix = [{
    type = "local";
    source = "${nixSystemsRoot}/modules/core/vars/omnix.sh";
    dest = "~/.config/env/omnix.sh";
  }];

  # Phoenix-specific sync items
  phoenix = [
    {
      type = "git";
      source = "git@github.com:devswork-in/loomwork.git";
      dest = "~/loomwork";
    }
  ];

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
