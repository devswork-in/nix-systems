# Codex Preferences

## Worker delegation

- Prefer an idle, signed-in agy1/agy2/agy3 for bounded discovery, caller tracing, summaries and independent review when delegation saves meaningful work. From the target repo run `agy-profile list`, then `agy-profile run <profile> --model gemini-3.8-flash-high --mode plan --sandbox --print-timeout 2m --print '<bounded task>'`. Require pwd, Git root and short HEAD first; discard mismatched findings.
- Use only Gemini 3.8 on AGY to preserve quota. On quota/auth/rate failure try another eligible profile with the same model, then work locally; no Pi fallback unless requested. Keep prompts and returned evidence short, avoid duplicate reviews, and do trivial checks locally.
- Use delegated edit capabilities only when the user explicitly requests delegated edits or implementation.
- Do not delegate architecture decisions, destructive operations, secrets, production changes, or final validation.
- Treat delegated output as advisory. Review its findings and diff, then run the relevant checks yourself.

## Scope

- Do not mutate adjacent systems or external configuration without authorization.
- Diagnose out-of-scope issues without changing them.
