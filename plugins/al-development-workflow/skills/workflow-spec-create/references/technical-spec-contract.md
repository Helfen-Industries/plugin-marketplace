# Technical Specification Contract

The canonical handoff between specification, estimation, and implementation is one Markdown document stored at `specs/{requirement-source-id-or-NOID}-{short-slug}.md`.

## Identity

- The **entry work item** is the assigned Task or other reference that started the workflow. Keep it in metadata and traceability.
- The **requirement source** owns the business title, description, acceptance criteria, artifact identity, and scenario prefix. For an Azure DevOps Task, it is the verified direct parent User Story.
- When the entry item itself owns the requirement, use the same identity for both roles.
- Do not name specifications or scenarios from an entry Task when a parent User Story is the requirement source.

## Invariants

- Write in the requirement's language while preserving section order and table columns.
- Keep every numbered section. Use `- None` in the document language when a section does not apply.
- Preserve source requirements, acceptance criteria, confirmed decisions, and explicit exclusions without weakening them.
- Keep requirement-source content and entry-item implementation constraints separately attributable; never merge contradictory statements silently.
- Distinguish verified workspace or dependency facts from user decisions.
- Do not assign IDs to new AL objects. Record existing base-object IDs when verified; reserve new IDs during implementation.
- List objects and implementation steps in dependency order: data structures, UI and reports, logic and events, cross-cutting concerns, tests.
- Give every acceptance criterion at least one stable test scenario ID: `{requirement-source-id-or-NOID}-{feature-code}-{NNN}`.
- Keep effort, pricing, and token estimates out of the spec. Estimation is a separate derived artifact.

## Required sections

1. Metadata and readiness
2. Objective and business context
3. Verified requirements and acceptance criteria
4. In scope
5. Out of scope
6. Confirmed decisions
7. Assumptions and dependencies
8. Solution overview and architecture
9. Data model
10. UI and reports
11. Logic, events, and extensibility
12. Setup, permissions, and translations
13. Integrations and APIs
14. Non-functional and upgrade requirements
15. Test scenarios
16. Ordered implementation plan
17. Object inventory
18. Self-review

## Detail threshold

The spec must let an AL developer implement without making product or architecture decisions. Name proposed objects, fields, types, captions, placement, keys, relations, procedures, invocation points, errors, events, permissions, translations, migration behavior, and validation where relevant. Omit trivial getters and incidental syntax.

Each new or extended object gets its own entry. Do not hide multiple objects behind one generic row. Use existing repository conventions and installed AL guidance for naming, namespaces, events, performance, errors, translations, tests, and code style.

## Readiness gate

Set readiness to `Ready for implementation` only when:

- every implementation-critical decision is resolved and shared understanding is explicitly confirmed
- every requirement and acceptance criterion maps to concrete design and validation
- all named existing objects and extension points are supported by workspace source or verified symbols
- assumptions, exclusions, permissions, translations, upgrade impact, and unresolved retrieval gaps are explicit
- no placeholder, undecided option, or hidden dependency remains

Otherwise set readiness to `Blocked` and list the exact gaps. Estimation may describe a blocked spec but must not present a reliable fixed estimate. Implementation must not begin from a blocked spec.

## Consumers

- `workflow-spec-estimate` reads the object inventory, implementation steps, risks, and assumptions without changing the spec.
- `workflow-spec-implement` treats requirements, confirmed decisions, exclusions, and test mappings as the behavior contract.
- `workflow-code-review` simplifies and reviews the completed implementation while preserving this contract.
- `workflow-pull-request-create` derives customer documentation, implemented-test documentation, and PR traceability without changing this contract.
