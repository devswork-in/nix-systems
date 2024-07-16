# Nix-Systems : Nix Config across my systems
Configures NixOS and Home-Manager as NixOS Module to manage user with my configs across systems which I use.

## To build and test a demo-vm from this config on a Nix System
```
nixos-rebuild build-vm --flake .#phoenix --fast
```
## To deploy the config to cloud
```
deploy --targets .#phoenix
```

## Note you will need to add Host details in your `~/.ssh/config` file somewhat like this
```
Host phoenix
  HostName 127.0.0.0
  User creator54
  IdentityFile /home/creator54/.ssh/id_rsa_gmail
  Compression yes
  LogLevel QUIET
  IdentitiesOnly yes
```
