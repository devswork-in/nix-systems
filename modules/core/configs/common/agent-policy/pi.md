# Pi Preferences

## Context discipline

- Use targeted searches and line ranges. Do not dump large files, directories, logs, or unchanged code into context.
- Delegate broad scans, repetitive edits, and heavy generation when a cheaper capable worker is available.
- Keep planning, architecture decisions, integration, risky actions, and final validation in the parent.

## Delegation

- Prefer the cheapest capable route. Do not delegate trivial one-shot lookups.
- Give workers self-contained prompts with the exact scope, paths, constraints, and expected output.
- Never accept delegated edits blindly: inspect the diff, verify correctness, and run relevant checks.
- On quota, try another available route once. On authentication failure, stop and request login instead of hiding the error.

## Tooling

- Prefer Chrome DevTools for browser inspection when available.
- Keep command output bounded and avoid interactive commands in unattended work.
