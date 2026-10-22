# Usage

Build, deploy, and manage systems.

## Builds

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure  # Build & switch
sudo nixos-rebuild test --flake .#<hostname> --impure    # Test only
sudo nixos-rebuild build --flake .#<hostname> --impure   # Build only
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
nix run github:serokell/deploy-rs -- .#phoenix-arm
```

### VM Test

```bash
nixos-rebuild build-vm --flake .#phoenix-x86 --impure
./result/bin/run-*-vm
```

`phoenix-x86` is VM-only. Never deploy it to the `phoenix` hostname.

## Phoenix gateway model refresh

`gateway-model-refresh.timer` refreshes the OpenCode CLI free-model catalog daily,
with up to 30 minutes of randomized delay and catch-up after downtime. It uses the
running hub's bundled CLI and updates the catalog through the management API.
Other providers and combo definitions are unchanged; unavailable combo targets
are reported in the journal. Refreshes perform discovery only, not inference.
An empty, failed, or unverifiably free discovery leaves the gateway catalog intact.
This service manages the entire `opencode-cli` model selection; manual selections
are replaced on its next successful run. Avoid editing that provider during refresh.

After deploying the configuration, refresh manually and inspect the result:

```bash
ssh phoenix sudo systemctl start gateway-model-refresh.service
ssh phoenix systemctl status gateway-model-refresh.service
ssh phoenix journalctl -u gateway-model-refresh.service -n 30 --no-pager
ssh phoenix systemctl list-timers gateway-model-refresh.timer
```

Each completed oneshot can be started again; concurrent starts do not launch a
second refresh. Disable scheduled refresh with
`sudo systemctl stop gateway-model-refresh.timer` on Phoenix; manual starts still work.

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
