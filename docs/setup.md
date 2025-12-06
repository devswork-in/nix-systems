# Setup

Install and configure the system.

## Installation

```bash
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/devswork-in/nix-systems/main/setup.sh | bash -s /dev/nvme0n1 omnix'
```

Replace `/dev/nvme0n1` with target device and `omnix` with system name.
**Warning:** Erases all data on device.

## Configuration

- User settings: [`config.nix`](../config.nix)
- Secrets: `secrets/user-secrets.nix` (git-ignored)
- See [flake.nix](../flake.nix) for secrets handling

## Apply

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
```

## Verify

```bash
nix-repo-sync-logs | tail -20
```
