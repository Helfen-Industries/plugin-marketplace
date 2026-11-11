# Technical Specification - {Requirement source title} ({Requirement source reference})

## Metadata and readiness

- **Requirement source**: {system, type, ID, title, and canonical reference}
- **Entry work item**: {system, type, ID, title, and canonical reference}
- **Entry-to-requirement relation**: {direct parent / same item / direct input}
- **Base specification**: {relative path of the implemented spec this delta changes; delta specs only}
- **Version**: {n}
- **Readiness**: Ready for implementation / Blocked
- **Blocking gaps**: {exact gaps; blocked specs only}
- **Language**: {language}
- **Confirmed understanding**: {who confirmed which summary, and when}

## Part A - Concept

### 1. Summary

{Intention: why the business needs the change. Benefit: what improves for whom. Solution: what the system does differently. 3-5 sentences.}

### 2. Initial situation and context

{Actors and roles, affected business process, verified current behavior, the gap, and related prior work. At most 8 sentences or bullets.}

### 3. Target process

```mermaid
flowchart TD
    A[{Trigger}] --> B{"{Decision}"}
    B -->|{Condition}| C[{New behavior}]
    B -->|{Otherwise}| D[{Unchanged standard behavior}]
```

1. {Who does what, and how the system responds}
2. {5-8 steps in business language}

### 4. Scope

**In scope**

- {Business capability}

**Out of scope**

- {Explicit exclusion}

### 5. Key decisions

| Decision   | Answer             | Consequence       | Ref   |
| ---------- | ------------------ | ----------------- | ----- |
| {Question} | {Confirmed answer} | {Business effect} | D-001 |

## Part B - Technical design

### 6. Solution design

- **Approach**: {How the catalog objects work together, as 3-6 sentences or an ordered chain of refs}
- **Technical flow**: {Mermaid sequence diagram when three or more objects interact through events or triggers}
- **Platform and dependencies**: {Application, platform, runtime, dependency apps with versions, and verified external objects}
- **Repository conventions**: {Affix, namespace, folders, and ID ranges; new IDs are reserved during implementation}
- **Verified assumptions**: {Fact the design relies on, with its evidence}
- **Rejected alternatives**: {Alternative and reason}

### 7. Object catalog

| Ref  | Type         | Name     | Change        | Base object              | Purpose   | File     |
| ---- | ------------ | -------- | ------------- | ------------------------ | --------- | -------- |
| O-01 | {Fixed type} | `{Name}` | New / Changed | {ID "Name" (app)} or `-` | {Purpose} | `{Path}` |

### 8. Object details

#### O-01 {Type} `{Name}`

{Type-specific content from the Object Details reference. For Changed objects, only the change.}

### 9. Cross-cutting concerns

#### 9.1 {Affected concern from the fixed list}

- {Decision-relevant detail}

### 10. Test scenarios

| Scenario ID                       | Scenario | Given          | When     | Then     | Acceptance criteria |
| --------------------------------- | -------- | -------------- | -------- | -------- | ------------------- |
| {RequirementId}-{FeatureCode}-001 | {Title}  | {Precondition} | {Action} | {Result} | AC-001              |

- **Manual validation**: {Scenario ID: reason it cannot be automated}

### 11. Ordered implementation plan

| Step | Objects / files             | Intended behavior | Validation                       |
| ---- | --------------------------- | ----------------- | -------------------------------- |
| 1    | O-01 `{Name}`; {Other file} | {Change}          | {Scenario IDs and focused check} |

## Part C - Appendix

### C1. Requirements and traceability

#### Requirements

| ID    | Requirement   | Source             |
| ----- | ------------- | ------------------ |
| R-001 | {Requirement} | {Source reference} |

#### Acceptance criteria

| ID     | Acceptance criterion   | Requirement |
| ------ | ---------------------- | ----------- |
| AC-001 | {Measurable criterion} | R-001       |

#### Entry-item constraints

| Constraint   | Entry source           | Relationship to requirement         |
| ------------ | ---------------------- | ----------------------------------- |
| {Constraint} | {Entry Task reference} | {Supports, narrows, or contradicts} |

#### Traceability

| Acceptance criterion | Objects | Scenarios                         | Steps |
| -------------------- | ------- | --------------------------------- | ----- |
| AC-001               | O-01    | {RequirementId}-{FeatureCode}-001 | 1     |

### C2. Decision log

| ID    | Decision   | Confirmed answer        | Implementation consequence |
| ----- | ---------- | ----------------------- | -------------------------- |
| D-001 | {Decision} | {User-confirmed answer} | {Effect on design}         |

### C3. Readiness and self-review

- **Requirement coverage**: {Result}
- **Completeness gate**: {Result of the five catalog checks}
- **Feasibility evidence**: {Workspace files and symbols checked, with versions}
- **Remaining risks**: {Risk and the scenario or check that covers it}

| Cross-cutting concern                   | Result                                                  |
| --------------------------------------- | ------------------------------------------------------- |
| Setup and initial data                  | Covered in {9.x or object ref} / Not affected: {reason} |
| Upgrade, migration, and compatibility   | Covered in {9.x or object ref} / Not affected: {reason} |
| Permissions and entitlements            | Covered in {9.x or object ref} / Not affected: {reason} |
| Translations and labels                 | Covered in {9.x or object ref} / Not affected: {reason} |
| Performance and data volume             | Covered in {9.x or object ref} / Not affected: {reason} |
| Telemetry and diagnostics               | Covered in {9.x or object ref} / Not affected: {reason} |
| Integrations and external interfaces    | Covered in {9.x or object ref} / Not affected: {reason} |
| Data classification, privacy, and audit | Covered in {9.x or object ref} / Not affected: {reason} |
| Extensibility and published contracts   | Covered in {9.x or object ref} / Not affected: {reason} |

### C4. Version history

| Version | Date   | Change    | Decisions |
| ------- | ------ | --------- | --------- |
| 2       | {Date} | {Summary} | D-0xx     |
