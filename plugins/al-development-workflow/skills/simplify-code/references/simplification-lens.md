# Simplification Lens

Use this lens to identify evidence-backed simplification opportunities. Do not equate shorter code with simpler code.

## Meaningful complexity

Prefer changes or findings that:

- remove duplicated logic while keeping variants explicit
- simplify control flow with early exits or clearer conditions
- replace unnecessary indirection with direct code
- extract a helper only when it gives a repeated operation or substantial concept a stable name
- narrow variable scope and remove dead variables, unreachable branches, stale comments, and obsolete helpers
- consolidate inconsistent error, validation, or data-conversion paths
- use existing repository abstractions instead of introducing parallel ones
- keep user-facing strings, localization, error handling, and AL conventions consistent with the codebase

## AI slop

Identify artifacts that add volume without carrying intent:

- comments or documentation that merely restate the code
- excessive headings, step comments, explanatory prose, or generated summaries inside source files
- one-use wrappers, pass-through helpers, and interfaces that add no meaningful boundary
- speculative configuration, extension points, fallback paths, compatibility shims, or generic frameworks not required by current behavior
- repetitive guard clauses for impossible states or checks already guaranteed by the caller or type system
- verbose logging, placeholder TODOs, unused options, and defensive error handling that hides failures
- duplicated tests, tautological assertions, and tests coupled to implementation detail rather than behavior
- inconsistent naming or structure that ignores nearby code in favor of generic generated patterns

Keep necessary domain rules explicit, preserve comments that explain why, and do not collapse distinct behavior merely because it looks similar. A finding is actionable only when evidence identifies the complexity, the affected behavior, and the expected maintenance benefit.
