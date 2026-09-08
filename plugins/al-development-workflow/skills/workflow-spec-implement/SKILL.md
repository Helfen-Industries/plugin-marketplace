---
name: workflow-spec-implement
description: Implement a ready canonical Business Central AL technical specification in dependency order with object-ID reservation, focused tests, and incremental validation. Use only when explicitly asked to implement an approved spec.
argument-hint: <path to canonical technical spec>
user-invocable: true
disable-model-invocation: true
---

# Implement Technical Spec

Implement one canonical spec as the behavior contract. Read the [Technical Specification Contract](../workflow-spec-create/references/technical-spec-contract.md) before editing. The explicit invocation authorizes changes required by the named ready spec, but not unrelated cleanup, external-system writes, publishing, or pull-request creation.

## Preconditions

Require a spec path with readiness `Ready for implementation`. Fail closed when it contains open decisions, placeholders, unsupported existing-object claims, missing acceptance mappings, or contradictory requirements. Do not implement from an estimate or reconstruct a spec from its summary.

## Process

1. Validate the spec structure, entry work item, authoritative requirement source, and their relation. Trace every requirement and acceptance criterion from the requirement source to design, implementation steps, and tests; retain the entry Task as traceability and implementation-constraint provenance. Inspect the current workspace, relevant call sites, tests, and conventions; apply [AL Symbols MCP](../mcp-al-symbols/SKILL.md) for compiled dependencies. Done when the spec still matches the workspace or every drift conflict is reported.
2. Build an execution checklist from the ordered implementation plan. Preserve unrelated user changes and keep exclusions visible. Load the applicable AL guidance for naming, namespaces, events, performance, error handling, translations, testing, and style. Done when each planned edit has an owning file or a proposed new object and a focused validation route.
3. Before creating any AL object, call `vjeko-al-objid_getNextObjectId` with its object type and absolute target path. Use the returned ID; never guess, reuse, or reserve IDs during specification. If multiple configured ranges remain ambiguous, ask the user to choose. Done when every new object being created has a committed unique ID.
4. Implement the smallest dependency-ordered slice: data structures, UI and reports, logic and events, cross-cutting concerns, then tests. After the first substantive edit, immediately run the narrowest executable check for that slice before continuing. Done when each slice satisfies its mapped requirements and focused validation.
5. Add or update automated tests from the stable scenario IDs. Apply [Run AL Tests TDD](../al-test-run-tdd/SKILL.md) for each behavior and [Document AL Test Scenarios](../al-test-document-scenarios/SKILL.md) when scenario documentation is missing or stale. Preserve scenario intent rather than coupling tests to incidental implementation. Do not create permission-only tests when the spec records permissions as configuration requirements. Done when every acceptance criterion has executable red-green evidence or a documented manual validation reason.
6. Run the strongest available focused tests, AL build and analyzers, and diagnostics required by the repository. Compare the final diff with the spec and remove no unrelated code. Done when validation passes, every implementation step is accounted for, and deviations are either corrected or explicitly approved.

If implementation evidence exposes a missing product decision, stop and return to clarification/specification; do not silently alter the contract. If a verified workspace fact makes the design impossible, report the exact conflict and keep the spec and implementation blocked.

## Output

Report:

- spec implemented and requirements covered
- entry work item and requirement source
- files and AL objects changed, including reserved IDs
- tests and validation results
- approved deviations from the spec
- blockers or residual manual checks

End a fully validated implementation with `Ready for code review`. Run [Review AL Implementation](../workflow-code-review/SKILL.md) as the separate final local gate before pull-request preparation.
