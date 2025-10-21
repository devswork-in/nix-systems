# NixOS Systems Configuration

This repository contains NixOS configurations for multiple systems.

## Project Structure

```
.
├── modules/          # NixOS modules
│   ├── essential/    # Essential/core system functionality
│   │   ├── base/     # Base NixOS system configurations
│   │   ├── core/     # Core system configurations required for any system
│   │   ├── networking/ # Network-related modules
│   │   ├── packages/ # Package configurations (common, server, desktop)
│   │   │   ├── common/ # Common packages for all systems
│   │   │   ├── server/ # Server-specific packages
│   │   │   └── desktop/ # Desktop-specific packages
│   │   ├── configs/  # Configuration files (common, server, desktop)
│   │   │   ├── common/ # Common configs for all systems
│   │   │   ├── server/ # Server-specific configs
│   │   │   └── desktop/ # Desktop-specific configs
│   │   ├── server-config.nix # Complete server home-manager config
│   └── addons/       # Optional functionality and enhancements
│       ├── apps/     # Application packages
│       ├── desktop/  # Desktop environment configurations
│       ├── extras/   # Extra configurations
│       ├── services/ # Service-related modules (Docker, Flatpak, etc.)
├── systems/          # System-specific configurations
│   ├── omnix/       # Omnix system
│   ├── cospi/       # Cospi system
│   ├── server/      # Server system
│   ├── blade/       # Blade system
│   └── phoenix/     # Phoenix system
├── flake.nix        # Main flake configuration
└── config.nix       # Global configuration
```

## One Step Setup
Live boot a NixOS USB and run

```sh
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/Creator54/nix-systems/refs/heads/main/setup.sh | bash -s /dev/nvme0n1 omnix'
```

## Building and Testing a Demo-VM

To build and test a demo-VM from this config on a Nix System:

```sh
nix run nixpkgs/release-23.11#nixos-rebuild -- build-vm --flake .#phoenix --fast
```
```sh
nix run nixpkgs/release-23.11#nixos-rebuild -- build-vm --flake github:creator54/nix-systems#phoenix --fast
```

## Running with deploy-rs

To run with [deploy-rs](https://github.com/serokell/deploy-rs):

```sh
nix run nixpkgs/release-23.11#deploy-rs -- .#phoenix
```
```sh
nix run nixpkgs/release-23.11#deploy-rs -- github:creator54/nix-systems#phoenix
```

## SSH Configuration

Add the following Host details to your `~/.ssh/config` file:

```
Host phoenix
HostName <server_ip_address>
User <server_user_name>
IdentityFile <full_path_private_ssh_key>
Compression yes
LogLevel QUIET
IdentitiesOnly yes
```

## Installing NixOS Config Locally

To install a NixOS config locally:

```sh
sudo nixos-rebuild switch --flake .#<flake>
```
```sh
sudo nixos-rebuild switch --flake github:creator54/nix-systems#<flake>
```

## Installing Different Profiles on Different Systems via nix run

To install different profiles on different systems via `nix run`:

```sh
nix run nixpkgs/release-23.11#deploy-rs -- .#server --hostname=phoenix
```
```sh
nix run nixpkgs/release-23.11#deploy-rs -- github:creator54/nix-systems#server --hostname=phoenix
```
