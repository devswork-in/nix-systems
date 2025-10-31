# Setup

Installation and configuration.

## Installation

```bash
sudo sh -c 'curl -sSL https://raw.githubusercontent.com/Creator54/nix-systems/main/setup.sh | bash -s /dev/nvme0n1 omnix'
```

Replace `/dev/nvme0n1` with your device and `omnix` with your system (omnix, blade, cospi, server, phoenix).

**Warning:** Erases all data on target device.

## Configuration

### User Settings

Edit [`config.nix`](../config.nix):

```nix
{
  user = {
    name = "username";
    email = "user@example.com";
    hashedPassword = "...";  # mkpasswd -m sha-512
    sshKeys = [ "ssh-rsa ..." ];
  };
  
  services = {
    nextcloud.enable = false;
    whoogle.enable = true;
  };
}
```

### Secrets (Optional)

Create `secrets/user-secrets.nix` (git-ignored):

```nix
{
  hashedPassword = "...";
}
```

### Apply Changes

```bash
sudo nixos-rebuild switch --flake .#<hostname> --impure
```

## Verification

```bash
repo-sync-logs | tail -20
```
