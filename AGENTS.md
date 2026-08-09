# Repository instructions

Read `CONTEXT.md` before changing system composition.

- Put genuinely universal behavior in `profiles/base.nix`, role behavior in
  `profiles/desktop.nix` or `profiles/server.nix`, and hardware behavior under
  the matching `hosts/<name>/` directory.
- Build variants by inheriting the existing attribute set and replacing only
  changed nested values. Do not duplicate a full configuration to override it.
- Do not generalize AMD, Intel, Niri, bootloader, filesystem, or cloud settings.
- Keep filesystem devices on their assigned stable names (for example
  `/dev/sda1`); do not replace them with UUID paths.
- Treat `omnix` and `phoenix-arm` as active. Dormant outputs must still evaluate,
  but must not be deployed without an explicit request.
- `phoenix-x86` is VM-only. Never add it to `deploy.nodes`; only
  `phoenix-arm` represents the active Phoenix server.
- Keep `nix-repo-sync` editable via `NIX_CONFIG_DIR`. Do not add automatic sudo
  rebuilds or application deployment hooks to synchronization.
- Never deploy Phoenix while its root filesystem lacks at least 8 GiB free.
- Do not use sudo during repository validation. The operator performs
  `nixos-rebuild test/switch` after build validation.

Run before handoff:

```bash
git diff --check
nix flake check --all-systems --no-build --impure
nix eval --impure .#nixosConfigurations.<name>.config.system.build.toplevel.drvPath
```

Use `nixos-rebuild build-vm --flake .#omnix --impure` for GUI validation and
`nixos-rebuild build-vm --flake .#phoenix-x86 --impure` for fast server VM
validation. Deploy production only with
`nix run github:serokell/deploy-rs -- .#phoenix-arm`.
