# Technical Specification Contract

The canonical handoff between specification, estimation, implementation, review, and documentation is one Markdown document stored at `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`. Keep derived planning artifacts, including `estimate.md`, in the same plan folder; separate `specs` and `estimates` folders are not used.

## Identity

- The **entry work item** is the assigned Task or other reference that started the workflow. Keep it in metadata and traceability.
- The **requirement source** owns the business title, description, acceptance criteria, artifact identity, and scenario prefix. For an Azure DevOps Task, it is the verified direct parent User Story.
- When the entry item itself owns the requirement, use the same identity for both roles.
- Do not name specifications or scenarios from an entry Task when a parent User Story is the requirement source.

## Change requests

Treat an existing spec as **implemented** when its `New` catalog objects (for older specs: its planned new objects) exist in the workspace, its implementation branch has commits, or the user states that implementation has started.

- **Same requirement source, spec not implemented**: update the spec in place. Increment `Version`, keep existing object refs and requirement, criterion, decision, and scenario IDs stable, continue their numbering for additions, and add a C4 row.
- **Same requirement source, spec implemented**: create a **delta spec** in its own plan folder with a new slug and never append to the implemented spec. Continue the base spec's requirement, criterion, and decision numbering and keep scenario IDs unique for the requirement source.
- **Different requirement source**, such as a change-request work item or a later direct requirement: create its own spec and never append it to another requirement source's spec. Make it a delta spec when it changes behavior specified in an existing spec; otherwise make it a new spec whose initial situation references the delivered feature. Its numbering starts at `001`.
- A delta spec links its base in `Base specification`, describes the delivered state as its initial situation, and catalogs only objects it creates or changes. Leave the base spec unchanged. Object refs are local to each spec and start at `O-01`.

## Structure

Keep these English headings in this order as stable anchors for consumers. Write all content in the requirement's language.

| Heading                           | Content                                                                                                             |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Metadata and readiness            | Identities, base specification for deltas, version, readiness, blocking gaps, language, confirmed understanding     |
| **Part A - Concept**              |                                                                                                                     |
| 1. Summary                        | Intention, business benefit, and solution in 3-5 sentences                                                          |
| 2. Initial situation and context  | Actors, affected process, verified current behavior, gap, and related prior work in at most 8 sentences or bullets  |
| 3. Target process                 | Required Mermaid flowchart of at most about 12 nodes plus 5-8 numbered steps, including unchanged standard paths    |
| 4. Scope                          | In-scope capabilities and explicit exclusions in business language                                                  |
| 5. Key decisions                  | At most 7 confirmed decisions that shape the solution, each with consequence and decision ID; all others stay in C2 |
| **Part B - Technical design**     |                                                                                                                     |
| 6. Solution design                | Object interaction, platform and dependencies, conventions, verified assumptions, rejected alternatives             |
| 7. Object catalog                 | One row per AL object                                                                                               |
| 8. Object details                 | One block per catalog row in catalog order                                                                          |
| 9. Cross-cutting concerns         | Affected concerns only                                                                                              |
| 10. Test scenarios                | Stable Given/When/Then scenarios mapped to acceptance criteria                                                      |
| 11. Ordered implementation plan   | Dependency-ordered steps naming catalog refs and validation                                                         |
| **Part C - Appendix**             |                                                                                                                     |
| C1. Requirements and traceability | Requirements, acceptance criteria, entry-item constraints when present, and the traceability matrix                 |
| C2. Decision log                  | Every confirmed decision with its implementation consequence                                                        |
| C3. Readiness and self-review     | Gate results, cross-cutting check, feasibility evidence, remaining risks                                            |
| C4. Version history               | Only from version 2                                                                                                 |

Part A must let a consultant without AL knowledge review intention, process, and scope on about two printed pages. Use business vocabulary and page or field captions; do not name procedures, events, files, internal field names, or object IDs there.

Omit what does not apply instead of writing `None`: optional sections, attribute lines, and table rows that have no content. Write `Base specification` only for delta specs, `Blocking gaps` only for blocked specs, entry-item constraints only when the entry item adds them, and C4 only from version 2. C3 is the only place for not-affected evidence.

## Object catalog

Columns: `Ref | Type | Name | Change | Base object | Purpose | File`.

- **Ref**: `O-01`, `O-02`, ... Refs are stable labels, not positions; rows added by an in-place update take the next free number.
- **Type**: exactly one entry from the type list below, including its qualifier when it has one.
- **Name**: exact AL object name; add the object ID for existing objects.
- **Change**: `New` when the object does not exist yet, including new extension objects; `Changed` when an existing workspace object is modified.
- **Base object**: verified ID, name, and owning app of the extended, customized, or implemented object; `-` otherwise.
- **Purpose**: one short clause.
- **File**: workspace-relative path; proposed path following repository conventions for new objects. A common root declared under Repository conventions may be omitted.

Order rows by group, then by type in listed order, then by dependency.

| Group                           | Types in catalog order                                                                                                   |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Data structures                 | `enum`, `enumextension`, `table`, `tableextension`                                                                       |
| UI and reports                  | `page`, `pageextension`, `pagecustomization`, `profile`, `profileextension`, `report`, `reportextension`, `controladdin` |
| Logic, events, and integrations | `interface`, `codeunit`, `page (API)`, `query`, `query (API)`, `xmlport`, `dotnet`                                       |
| Cross-cutting                   | `permissionset`, `permissionsetextension`, `entitlement`, `codeunit (Install)`, `codeunit (Upgrade)`                     |
| Tests                           | `codeunit (Test library)`, `codeunit (Test)`                                                                             |

Report layout files, XLIFF files, `app.json`, and scenario documents are not catalog rows. Specify layouts in the owning report's details, `app.json` and XLIFF changes under cross-cutting concerns, and scenario documents in the Ordered implementation plan.

## Completeness gate

1. Every AL object the work creates or modifies appears exactly once in the catalog, wherever the spec mentions it. Every existing object whose code, members, or signatures change is a `Changed` row. Base objects, event publishers, and unchanged dependencies are referenced, not cataloged.
2. Every catalog row has exactly one Object details block, in catalog order, headed `{Ref} {Type} {Name}`.
3. Every new or changed member is defined in exactly one details block: field, key, enum value, control, action, request-page field, layout, procedure, published event, event subscriber, permission, and label.
4. Every catalog row is covered by at least one Ordered implementation plan step, and every step names only existing refs.
5. C1 maps every acceptance criterion to at least one catalog ref, scenario, and plan step.

Write details according to [Object Details](object-details.md).

## Cross-cutting concerns

Evaluate every concern in this order. Write a `9.x` subsection only for affected concerns whose decisions are not already complete in an object details block, and record every concern in C3 as `Covered in {9.x or object ref}` or `Not affected: {reason}`.

1. Setup and initial data
2. Upgrade, migration, and compatibility
3. Permissions and entitlements
4. Translations and labels
5. Performance and data volume
6. Telemetry and diagnostics
7. Integrations and external interfaces
8. Data classification, privacy, and audit
9. Extensibility and published contracts

## Invariants

- Preserve source requirements, acceptance criteria, confirmed decisions, and explicit exclusions without weakening them.
- Keep requirement-source content and entry-item implementation constraints separately attributable; never merge contradictory statements silently.
- Distinguish verified workspace or dependency facts from user decisions.
- Do not assign IDs to new AL objects, fields, or enum values. Record verified IDs of existing objects; new IDs are reserved during implementation.
- Order implementation steps by dependency: data structures; UI and reports; logic, events, and integrations; cross-cutting concerns; tests.
- Give every acceptance criterion at least one stable test scenario ID: `{requirement-source-id-or-NOID}-{feature-code}-{NNN}`. List scenarios that cannot be automated with their manual-validation reason.
- Keep effort, pricing, and token estimates out of the spec. Estimation is a separate derived artifact.

## Detail threshold

The spec must let an AL developer implement without making product or architecture decisions. Name proposed objects, fields, types, captions, placement, keys, relations, procedures, invocation points, errors, events, permissions, translations, migration behavior, and validation where relevant. Omit trivial getters and incidental syntax. Use existing repository conventions and installed AL guidance for naming, namespaces, events, performance, errors, translations, tests, and code style.

## Readiness gate

Set readiness to `Ready for implementation` only when:

- every implementation-critical decision is resolved and shared understanding is explicitly confirmed
- the completeness gate passes
- all named existing objects and extension points are supported by workspace source or verified symbols
- every cross-cutting concern is covered or justified in C3, and unresolved retrieval gaps are explicit
- no placeholder, undecided option, or hidden dependency remains

Otherwise set readiness to `Blocked` and list the exact gaps. Estimation may describe a blocked spec but must not present a reliable fixed estimate. Implementation must not begin from a blocked spec.

## Consumers

- `workflow-spec-estimate` reads the Object catalog, Ordered implementation plan, Test scenarios, solution design dependencies and assumptions, and C3 risks without changing the spec.
- `workflow-spec-implement` treats C1 requirements and acceptance criteria, C2 decisions, Out of scope, the Object catalog with its details, and Test scenarios as the behavior contract and executes the Ordered implementation plan.
- `workflow-code-review` maps the final diff to Object catalog rows and treats any AL object outside the catalog as a deviation.
- `workflow-customer-document-create` uses Part A as the business narrative and verifies it against the reviewed implementation.
- `workflow-pull-request-create` derives customer documentation, implemented-test documentation, and PR traceability without changing this contract.
- `al-test-document-scenarios` adopts the scenario IDs, titles, and acceptance-criterion mapping from Test scenarios.
