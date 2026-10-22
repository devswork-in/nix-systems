# Phoenix lockout recovery

Use this when `ssh phoenix` fails after a deploy. Phoenix (`phoenix-arm`) is an
OCI Ampere instance.

Set these first. The values come from the OCI console and your local SSH
config:

```bash
REGION=<oci region>  I=<instance OCID>  KEY=<path to RSA private key>
PUBLIC_IP=<public IP>  TS_IP=<tailscale IP>  USER_NAME=<admin user>
GATEWAY_HOST=<gateway hostname>
```

## 1. Classify the failure

Run from a workstation:

```bash
ping -c2 $PUBLIC_IP
tailscale ping phoenix
curl -sk -o /dev/null -w '%{http_code}\n' https://$GATEWAY_HOST/healthz
ssh -v -o BatchMode=yes -o IdentitiesOnly=yes -i $KEY \
  $USER_NAME@$TS_IP true 2>&1 | grep -E 'Remote protocol|Offering|denied|kex_exchange'
```

| Symptom | Likely cause | Go to |
| --- | --- | --- |
| No ping or Tailscale | Instance down or stuck | 2 |
| `kex_exchange_identification`, no banner | sshd hung or the host is shutting down | 2 |
| Banner, key offered, `Permission denied (publickey)` with the configured key | Login shell missing, bad home permissions, or missing authorized keys | 3 |

A correct key that is rejected is almost never a key problem. sshd refuses
users whose login shell does not exist. Check the shell first.

## 2. Reboot

Re-authenticate if the CLI session has expired:

```bash
oci session authenticate --region $REGION --profile-name DEFAULT
oci compute instance action --instance-id $I --action RESET --auth security_token
```

- Use `RESET`, not `SOFTRESET`. A soft reset waits for the guest to shut down
  cleanly and can sit in `STOPPING` for 10 or more minutes.
- While the instance is in `STOPPING`, any other action returns `Conflict`.
  Wait for it to finish.

## 3. Get a console

Create a console connection. OCI accepts RSA keys only:

```bash
oci compute instance-console-connection create --instance-id $I \
  --ssh-public-key-file $KEY.pub --auth security_token
CC=<console connection OCID>
```

The serial service offers only legacy `ssh-rsa` host keys, so allow them
explicitly. Without these options the connection fails silently:

```bash
P="ssh -i $KEY -o IdentitiesOnly=yes -W %h:%p -p 443 $CC@instance-console.$REGION.oci.oraclecloud.com"
O="-i $KEY -o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"

# Serial console: shows the kernel and systemd log and a getty. Exit with `~.`
ssh $O -o ProxyCommand="$P" $I

# VNC console: the only place the GRUB menu is drawn
ssh $O -o ProxyCommand="$P" -N -L localhost:5900:$I:5900 $I
nix shell nixpkgs#tigervnc -c vncviewer localhost:5900
```

A password login on the serial getty fails the same way as SSH when the login
shell is missing (`Cannot execute .../fish`). The NixOS login prompt cannot
fall back to `sh`.

## 4. Boot a previous generation

GRUB does not render on the serial console: its output goes straight from the
`efi_uga.mod` error to the kernel. Use VNC instead.

1. Open the VNC viewer and focus its window.
2. Run `RESET` from step 2.
3. Hold the down arrow while the instance boots. GRUB waits 5 seconds.
4. Choose **NixOS - All configurations**, then the newest known-good entry.
   Entries are listed newest first, so the second entry is the generation
   before the broken deploy.
5. Log in over SSH or VNC.

In GRUB:

| Key | Action |
| --- | --- |
| Arrow keys, `Enter` | Select an entry |
| `e` | Edit the entry for this boot only |
| `Ctrl-x` or `F10` | Boot the edited entry |
| `Esc` | Discard the edit and go back |

Choose the fix by failure:

| Failure | What works |
| --- | --- |
| Bad config: missing shell, sshd, users, firewall | Boot the previous generation |
| A service hangs boot or shutdown | Edit the entry and append `systemd.mask=<unit>` to the `linux` line |
| Console only, no network | Append `systemd.unit=rescue.target`. This needs the root password, which was rejected during the incident |
| The initrd fails to mount root | Append `boot.shell_on_fail` to get an initrd shell |
| Every generation is broken | Detach the boot volume, attach it to another instance, and fix it there |

A generation selected in GRUB lasts for one boot only. Before the next reboot,
make the good generation the default:

```bash
sudo nixos-rebuild switch --rollback   # or deploy a fixed configuration
```

GRUB draws only on the VNC console. To make it appear on the serial console as
well, set this in Phoenix's configuration:

```nix
boot.loader.grub.extraConfig = ''
  serial
  terminal_input serial console
  terminal_output serial console
'';
```

## 5. Find the cause

```bash
journalctl -b -1 -u sshd --no-pager | tail -50
getent passwd $USER_NAME root
ls -l /run/current-system/sw/bin/fish
ls -ld ~ ~/.ssh ~/.ssh/authorized_keys /etc/ssh/authorized_keys.d/*
diff <(nix-store -qR /nix/var/nix/profiles/system | sort) \
     <(nix-store -qR /run/current-system | sort) | head
```

## 6. Fix and redeploy

Fix the configuration in this repository and deploy:

```bash
nix run github:serokell/deploy-rs -- .#phoenix-arm
ssh phoenix 'echo ok; ls /run/current-system/sw/bin/fish'
```

Remove the console connection afterwards:

```bash
oci compute instance-console-connection delete \
  --instance-console-connection-id $CC --force --auth security_token
```

## Incident

- **Trigger:** commit `35eea11` set
  `environment.systemPackages = lib.mkForce [...]` on Phoenix to trim the
  closure.
- **What broke:** `mkForce` replaced every package other modules add,
  including the `fish` binary from `programs.fish.enable`. The admin user and
  `root` both use fish, so sshd rejected valid keys and the serial getty could
  not start a shell.
- **Recovery:** `RESET`, then the VNC console, then the previous generation in
  GRUB.
- **Incomplete fix:** restoring only `fish` allowed login, but left core
  commands and D-Bus policy files missing. Activation failed with
  `Sender is not authorized to send message` and the gateway stayed down.
- **Fix:** remove the forced package list, retaining NixOS module defaults.
  Assertions in `profiles/base.nix` require login shells, coreutils, systemd
  and D-Bus in the system profile. Evaluation alone does not prove a safe
  switch: verify a fresh SSH login, service state and gateway health.
- **Gateway rollback:** native services and old containers use different
  state owners. Stop both before changing ownership, preserve tokens, and
  verify the target service user can read state. The pinned Headroom package
  needs `HEADROOM_HTTP2=false` because it lacks `h2`.
