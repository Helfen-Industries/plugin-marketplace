---
name: workflow-code-review
description: Review a completed Business Central AL implementation before pull-request creation. Run focused simplification, perform a findings-first whole-change review against the canonical spec, repair unambiguous defects, and prove tests and build remain green. Use after implementation or when preparing an AL change for pull request.
argument-hint: <canonical spec path and implemented change>
user-invocable: true
disable-model-invocation: true
---

# Review AL Implementation

Act as the final local quality gate. Read the canonical spec, apply [Code Simplify](../simplify-code/SKILL.md), then use the [AL Review Gate](references/al-review-gate.md) for the complete implementation diff.

## Preconditions

Require a ready canonical spec, a completed in-scope implementation, synchronized test scenarios, and passing focused implementation validation. Preserve unrelated working-tree changes. If the implementation or required tests are incomplete, return it to `workflow-spec-implement` or `al-test-run-tdd` instead of reviewing a partial result as final.

The explicit invocation authorizes behavior-preserving simplification and correction of unambiguous in-scope defects. It does not authorize new product behavior, unrelated cleanup, publishing, commits, pushes, external comments, or pull-request creation.

## Process

1. Establish the review boundary from the canonical spec, entry work item, requirement source, changed files, commits, and current diff. Separate implementation changes from unrelated user work. Done when every reviewed file maps to a requirement, test, documentation artifact, or necessary delivery metadata.
2. Reconfirm the baseline with the strongest focused test and build evidence already required by the implementation. If the baseline is red, report the failures and stop before simplification. Done when review begins from a known green baseline.
3. Apply [Code Simplify](../simplify-code/SKILL.md) to the bounded implementation. Re-run the narrowest relevant validation immediately after its first edit. Done when accepted simplifications preserve behavior and focused validation is green.
4. Review the complete resulting diff against the spec and AL review gate. Inspect full changed functions plus relevant call sites, tests, permissions, translations, upgrade paths, integration boundaries, and generated documentation. Report findings first, ordered Critical, High, Medium, Low, with file references, observed consequence, evidence, and smallest correction. Done when every changed behavior and cross-cutting concern has been reviewed or marked not applicable.
5. Correct only unambiguous in-scope findings whose intended behavior is already established by the spec. After each correction, rerun the narrowest falsifying check. Return product decisions, architecture changes, or scope expansion to specification; do not guess. Done when no Critical, High, or unresolved Medium finding remains.
6. Apply [Document AL Test Scenarios](../al-test-document-scenarios/SKILL.md) when implementation or test review exposes scenario-document drift. Run the focused tests, feature suite, full AL test app, build, analyzers, and diagnostics required by the repository. Inspect Test Results rather than command invocation alone. Done when all required validation is green and documentation matches implemented tests.
7. Re-read the final diff for accidental churn, secrets, unrelated files, stale comments, debug code, and unsupported deviations. Done when the final change is explainable from the spec and every remaining Low finding or residual risk is explicit.

## Output

Report findings first. Then report simplifications and fixes applied, requirements and scenarios reviewed, validation evidence, remaining Low findings, and approved deviations.

End with `Ready for pull request` and direct the user to [Create Pull Request](../workflow-pull-request-create/SKILL.md) only when no blocking finding, open product decision, unrelated change, missing test evidence, or documentation drift remains. Otherwise end `Blocked by review` with the minimum next action.