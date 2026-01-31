# Nix-Systems (NixOS)

[![NixOS](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?logo=nixos)](https://nixos.wiki/wiki/Flakes)

Opinionated NixOS configs for my devices.

## Layout

```
.
├── lib/                    # Helper functions (mkSystemConfig, mkAppImage)
├── profiles/               # Reusable profiles (base, desktop, server)
├── modules/
│   ├── addons/             # Addon modules
│   ├── apps/               # Application modules
│   ├── core/               # Core system modules
│   ├── desktop-utils/      # Desktop utilities and configurations
│   ├── desktops/           # Desktop environment modules
│   ├── server/             # Server configurations
│   ├── services/           # Service modules
│   └── extras/             # Additional modules
├── scheduled-scripts/      # Scheduled scripts
├── systems/                # Machine-specific configs
├── flake.nix               # Main configuration
├── config.nix              # User settings
└── sync-config.nix         # Sync configuration
```

## Quick Start

1. Boot NixOS ISO
2. Run setup script:

```bash
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/devswork-in/nix-systems/main/setup.sh | bash -s /dev/nvme0n1 omnix'
```

**Warning**: Wipes `/dev/nvme0n1`, repartitions & installs `omnix` flake.

## Systems

[omnix](systems/omnix/), [blade](systems/blade/), [cospi](systems/cospi/), [phoenix](systems/phoenix/)

## Commands

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure  # Build & switch
nix run nixpkgs#deploy-rs -- .#<hostname>               # Remote deploy
nix-repo-sync-force                                     # Force sync
nix-repo-sync-logs                                      # View logs
nix-cleanup --dry-run                                   # Cleanup preview
nix-cleanup                                             # Full cleanup
nix run nixpkgs#nixos-rebuild -- build-vm --flake .#<hostname> --fast  # VM test
```

## Deployment

### Phoenix (ARM)

**Remote Build** (Builds on target, fast):
```bash
nixos-rebuild --flake .#phoenix-arm --target-host phoenix --build-host phoenix switch --no-reexec -S
```

**Local Build** (Builds locally & pushes):
```bash
nixos-rebuild --flake .#phoenix-arm --target-host phoenix switch --no-reexec
```

## Docs

- [Setup](docs/setup.md)
- [Usage](docs/usage.md)
- [Modules](docs/modules.md)
- [Structure](docs/structure.md)
- [Repo-Sync](docs/repo-sync.md)
