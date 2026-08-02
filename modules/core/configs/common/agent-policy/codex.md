# Codex Preferences

## Pi delegation

- Use `$pi-worker` for bounded repository discovery, caller tracing, summaries, routine diagnosis, and independent review when it is responsive and cheaper.
- Use Pi edit mode only when the user explicitly requests delegated edits or implementation.
- Do not delegate architecture decisions, destructive operations, secrets, production changes, or final validation.
- Treat delegated output as advisory. Review its findings and diff, then run the relevant checks yourself.

## Scope

- Do not mutate adjacent systems or external configuration without authorization.
- Diagnose out-of-scope issues without changing them.
