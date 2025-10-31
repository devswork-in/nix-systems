# NixOS Systems Configuration

[![NixOS](https://img.shields.io/badge/NixOS-24.11-blue.svg?logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-informational.svg?logo=nixos)](https://nixos.wiki/wiki/Flakes)

Opinionated NixOS configurations for managing multiple machines with shared profiles and automated config synchronization.

## Quick Start

```bash
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/Creator54/nix-systems/main/setup.sh | bash -s /dev/nvme0n1 omnix'
```

## Documentation

- [Structure](docs/structure.md) - Repository layout and architecture
- [Setup](docs/setup.md) - Installation and configuration
- [Usage](docs/usage.md) - Building and deploying systems
- [Modules](docs/modules.md) - Available modules and services
- [Repo-Sync](docs/repo-sync.md) - Configuration synchronization
- [Development](docs/development.md) - Extending the system

## Repository Layout

```
.
├── lib/                    # Helper functions (mkSystemConfig, mkAppImage, mkRepoSync)
├── profiles/               # Reusable profiles (base, desktop, server)
├── modules/
│   ├── essential/          # Core functionality
│   ├── addons/             # Optional features
│   └── services/           # System services
├── systems/                # Machine-specific configs
├── flake.nix               # Main configuration
├── config.nix              # User settings
└── sync-config.nix         # Sync configuration
```

## Systems

- **omnix** - Desktop (GNOME + Pop Shell)
- **blade** - Server
- **cospi** - Desktop (GNOME)
- **server** - Basic server
- **phoenix** - Server (x86_64/aarch64)

## Common Commands

```bash
# Local rebuild
sudo nixos-rebuild switch --flake .#<hostname> --impure

# Remote deployment
nix run nixpkgs#deploy-rs -- .#<hostname>

# Force config sync
repo-sync-force

# View sync logs
repo-sync-logs
```

See [Usage](docs/usage.md) for complete command reference.