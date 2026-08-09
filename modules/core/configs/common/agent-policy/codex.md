# Codex Preferences

## Worker delegation

- Prefer any signed-in, non-running `agy*` profile for bounded repository discovery, caller tracing, summaries, routine diagnosis, and independent review. Run `agy-profile list`, then invoke the selected profile non-interactively from the repository root in plan and sandbox mode.
- On quota, rate-limit, or authentication failure, try another signed-in profile. Fall back to `$pi-worker` when no AGY profile is usable.
- Use delegated edit capabilities only when the user explicitly requests delegated edits or implementation.
- Do not delegate architecture decisions, destructive operations, secrets, production changes, or final validation.
- Treat delegated output as advisory. Review its findings and diff, then run the relevant checks yourself.

## Scope

- Do not mutate adjacent systems or external configuration without authorization.
- Diagnose out-of-scope issues without changing them.
