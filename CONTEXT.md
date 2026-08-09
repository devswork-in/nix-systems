# Repository context

This repository defines NixOS systems at three scopes:

- `profiles/`: behavior shared by a machine role (`desktop` or `server`).
- `modules/`: reusable capabilities, imported only where they are needed.
- `hosts/`: hardware and behavior belonging to one physical machine.

## Machines

| Output | Role | Hardware | Status | Purpose |
| --- | --- | --- | --- | --- |
| `omnix` | desktop | x86_64, AMD CPU/GPU | active | Daily Niri workstation |
| `phoenix-arm` | server | aarch64 cloud VM | active | Production deploy target |
| `phoenix-x86` | server | x86_64 VM | test only | Fast Phoenix VM validation |
| `server` | server | x86_64 | dormant | Preserved future system |
| `blade` | mixed legacy profile | x86_64 | dormant | Preserved pending a hardware-role audit |
| `cospi` | desktop | x86_64, Intel | dormant | Preserved future system |

Hardware-specific settings stay in the owning host. AMD/Niri choices on Omnix
must not become desktop defaults; Intel choices on Cospi must not affect Omnix.

`nix-repo-sync` intentionally supports editable, impure worktree inputs through
`NIX_CONFIG_DIR`. It synchronizes configuration only; application deployment is
a separate manual operation.
