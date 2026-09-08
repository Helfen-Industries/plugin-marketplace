---
name: simplify-code
description: Review a completed AL implementation before pull-request creation, then apply focused simplifications that improve readability and maintainability without changing intended behavior. Use after implementation and tests, or when asked to simplify, clean up, reduce AI slop, or prepare AL code for review.
argument-hint: <implemented AL change or files to simplify>
user-invocable: true

---

# Code Simplify

Run this workflow after implementation is functionally complete and before creating a pull request. Treat the current change set as the scope unless the user names specific files or behavior.

Apply the shared [Simplification Lens](references/simplification-lens.md) when reviewing and editing the implementation.

## Process

1. Establish the review scope from the user request and version-control changes. Read the complete changed functions plus the nearest tests, call sites, and local conventions needed to judge them. Do not include unrelated pre-existing changes. Done when every file under review is tied to the implementation being prepared for review.
2. Validate the current baseline with the narrowest available tests, compile, lint, or diagnostics. If the implementation is already failing, distinguish those failures from simplification opportunities before editing. Done when behavior has a known baseline or the validation blocker is explicit.
3. Review before editing. Identify only evidence-backed opportunities that preserve intended behavior and improve comprehension or maintenance. Rank findings by impact and skip changes whose benefit is speculative. Done when each proposed edit names the concrete complexity it removes and the behavior that must remain unchanged.
4. Apply the smallest coherent simplifications using repository conventions. After the first edit, run the narrowest relevant validation before continuing. Do not mix feature changes, broad redesigns, dependency upgrades, formatting churn, or unrelated cleanup into this pass. Done when accepted opportunities are implemented and each edit remains within scope.
5. Re-run focused validation, inspect the resulting diff, and remove stale code made obsolete by the simplification. Done when validation passes at least as strongly as the baseline, no unintended behavior or public contract changed, and the diff is smaller or easier to explain.

## Output

Report:

- scope reviewed
- simplifications applied, with the complexity each removed
- opportunities intentionally declined and why
- validation run and result
- remaining risks or blockers before pull-request creation

The workflow is complete when the implementation is behaviorally unchanged, focused validation passes, and every remaining abstraction or comment in the reviewed scope has a concrete purpose.
