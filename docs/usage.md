# Usage

Build, deploy, and manage systems.

## Builds

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure  # Build & switch
sudo nixos-rebuild test --flake .#<hostname> --impure    # Test only
sudo nixos-rebuild build --flake .#<hostname>            # Build only
sudo nixos-rebuild boot --flake .#<hostname> --impure    # Next boot

# From GitHub
sudo nixos-rebuild switch --flake github:devswork-in/nix-systems#<hostname> --impure
```

### Rollback

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --rollback
```

## Deploy

### SSH Config

Add to `~/.ssh/config`:

```
Host phoenix
    HostName <ip>
    User root
    IdentityFile ~/.ssh/id_rsa
```

### Remote

```bash
nix run nixpkgs#deploy-rs -- .#phoenix
nix run nixpkgs#deploy-rs -- github:devswork-in/nix-systems#phoenix
nix run nixpkgs#deploy-rs -- .#server --hostname=phoenix
```

### VM Test

```bash
nix run nixpkgs#nixos-rebuild -- build-vm --flake .#phoenix --fast
./result/bin/run-*-vm
```

## Systems

### New System

```bash
mkdir -p hosts/newhost
nixos-generate-config --show-hardware-config > hosts/newhost/hardware.nix
```

- See [hosts/omnix/configuration.nix](../hosts/omnix/configuration.nix) for structure
- Add to [`flake.nix`](../flake.nix), see [flake.nix](../flake.nix) for patterns

```bash
sudo nixos-rebuild switch --flake .#newsystem --impure
```

### Switch Profile

- Edit [`flake.nix`](../flake.nix) (desktop.nix, server.nix)
- See [flake.nix](../flake.nix) for usage

```bash
sudo nixos-rebuild switch --flake .#mysystem --impure
```

## Sync

```bash
nix-repo-sync-force                # Force sync
nix-repo-sync-logs                 # View logs
systemctl status nix-repo-sync.service # Status
```

## Monocle (AI Review)

Review AI agent code in real-time.

### Registration

Register Monocle with your agent (e.g., Gemini CLI):

```bash
monocle register gemini --global
```

### Neovim Integration

Launch Monocle from within Neovim:

- **`Alt+m`**: Toggle Monocle **Sidebar** (Vertical split). This matches your `Alt+t` terminal pattern.

### Tmux Integration

Launch Monocle in a **Popup** from anywhere:

- **`Alt+r`**: Open Monocle in a tmux floating popup.
- **`Ctrl+Space`**: Select "Monocle (Review)" from the command palette.

Monocle uses Neovim as its external editor (`Ctrl+g`).

