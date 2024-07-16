# Nix-Systems: [Nix](https://nixos.org/) Config across my systems

Configures NixOS and Home-Manager as NixOS Module to manage user with my configs across systems which I use.

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
