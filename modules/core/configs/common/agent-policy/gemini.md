# Personal Context

## Identity

- Profile: Solutions Engineer (Platform/PaaS) at PhonePe since May 2025; previously QA Automation and Product Engineer.
- Goal: transition to an SRE or Platform Engineering role at a remote-first company, targeting 25L+ base with code ownership.
- Current work: API Gateways and OpenTSDB at PhonePe. NixOS power user.
- `~/roadmaps` has project-specific study instructions; do not duplicate them globally.

## Environment

- OS: NixOS. Flake: `~/nix-infra/nix-systems`.
- Terminal: Kitty. Config: `~/nix-infra/nix-systems/modules/desktop-utils/kitty.conf`.
- Compositor: Niri on Wayland.
- Shell: Bash with direnv and workspace `.envrc` files.

## Common operations

- Rebuild: `sudo nixos-rebuild switch --flake ~/nix-infra/nix-systems`.
- Update: `nix flake update` from the flake repository.
- System diagnosis: inspect `journalctl -b`, Niri logs, and Kitty configuration.
- After hibernation, verify scrolling, input devices, compositor state, and time synchronization.

## Standing directives

- For production debugging, architecture decisions, or deep PhonePe technical work, record one resume-material bullet in `~/roadmaps/roadmaps/sre/progress.md`.
- Keep commits concise and separated by logical boundaries.
- Report out-of-scope cleanup opportunities instead of changing them.
- Store learned preferences in the platform's mutable memory, not this managed file.

## Career constraints

- Target roles: SRE, SDE-2, MTS, or Platform Engineer.
- Minimum offer: 25L+ base with code ownership.
- Active preparation: June through September 2026.
- Do not suggest an internal PhonePe transfer before approximately November 2026.

## Learned context

- Post-hibernate scroll breakage in Niri is recurring.
- Prefer generic names for shared tooling and specific paths for roadmap content.
- Kitty is the primary terminal; awrit is used for in-terminal web browsing.
