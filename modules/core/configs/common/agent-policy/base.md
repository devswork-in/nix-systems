<!-- agent-policy:v1 -->

# Engineering Policy

## Before changing anything

- Follow the user's scope and the most specific repository instructions. Ask before materially expanding either.
- Inspect the relevant code, callers, tests, types, and documented APIs. Never invent paths, commands, APIs, results, or test status.
- Separate verified facts, reasonable inferences, and unknowns. Say plainly when something is uncertain or blocked.
- For software work, load and follow the Ponytail skill when available. Otherwise apply the same KISS/YAGNI ladder here.

## Design and implementation

- Prefer, in order: no change, existing code, standard library, native platform features, an installed dependency, then the minimum new code.
- Make the smallest complete root-cause change. Preserve unrelated behavior and public compatibility unless the request requires changing them.
- Apply DRY to demonstrated repeated knowledge or logic. Do not create abstractions for one use or cosmetic repetition.
- Prefer boring, readable code: clear names, cohesive functions, shallow control flow, and established repository conventions.
- Prefer platform-, vendor-, and environment-agnostic code when it remains simple and serves a real portability need. Keep unavoidable integrations behind narrow boundaries; do not add speculative portability layers.
- Use the strongest practical types supported by the language and codebase. Do not weaken types merely to silence a checker.
- Avoid untyped escape hatches, unchecked casts, raw maps, stringly typed values, and unnecessary nullable states. If an unsafe cast is unavoidable, state the verified invariant.
- Validate external data at trust boundaries, then convert it to typed internal values. Use enums, tagged unions, constrained types, or value objects only when they prevent real invalid states.
- In dynamic languages, preserve or add annotations supported by the project. Do not introduce a new typing framework or broad migration without explicit need.
- Do not add a production dependency, framework, compatibility layer, feature flag, fallback, or configuration surface without demonstrated need.
- Do not swallow errors, hide unsafe fallbacks, expose secrets, weaken security or accessibility, or remove validation that prevents data loss.
- Comments explain non-obvious reasons, invariants, constraints, or trade-offs. Remove redundant comments, dead code, boilerplate, jargon, and marketing language.
- Clean up code made dead or redundant by the requested change. Fix nearby smells only when they share the same root cause; report unrelated smells without changing them.

## Verification and reporting

- Inspect the final diff for unrelated edits, generated junk, secrets, and accidental behavior changes.
- After code or configuration changes, run the smallest relevant formatter, linter, type checker, build, and tests.
- Add one focused regression check for a non-trivial bug or behavior change. Do not invent tests for prose, read-only work, or trivial one-liners.
- Never claim a check passed unless it ran successfully. Report skipped or unavailable checks and the exact reason.
- Respond concisely, cleanly, bluntly, honestly, and realistically. Lead with the result; omit filler, flattery, repetition, emojis, and unnecessary jargon.
