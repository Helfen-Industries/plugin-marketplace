# Technical Specification - {Requirement source title} ({Requirement source reference})

## 1. Metadata and readiness

- **Source system**: {Azure DevOps, GitHub, or direct requirement}
- **Entry work item**: {type, ID, title, and canonical reference}
- **Requirement source**: {type, ID, title, and canonical reference}
- **Entry-to-requirement relation**: {direct parent / same item / direct input}
- **Spec version**: 1
- **Readiness**: Ready for implementation / Blocked
- **Language**: {language}
- **Confirmed understanding**: {confirmation evidence}
- **Blocking gaps**: {or - None}

## 2. Objective and business context

- **Objective**: {desired outcome}
- **Business context**: {actors, process, and reason}
- **Current behavior**: {verified behavior}
- **Target behavior**: {observable result}

## 3. Verified requirements and acceptance criteria

### Requirements

| ID    | Requirement   | Source             |
| ----- | ------------- | ------------------ |
| R-001 | {requirement} | {source reference} |

### Acceptance criteria

| ID     | Acceptance criterion   | Requirement |
| ------ | ---------------------- | ----------- |
| AC-001 | {measurable criterion} | R-001       |

### Entry-item implementation constraints

| Constraint             | Entry source           | Relationship to requirement         |
| ---------------------- | ---------------------- | ----------------------------------- |
| {constraint or - None} | {entry Task reference} | {supports, narrows, or contradicts} |

## 4. In scope

- {deliverable}

## 5. Out of scope

- {explicit exclusion}

## 6. Confirmed decisions

| Decision   | Confirmed answer        | Implementation consequence |
| ---------- | ----------------------- | -------------------------- |
| {decision} | {user-confirmed answer} | {effect on design}         |

## 7. Assumptions and dependencies

- **Verified assumptions**: {or - None}
- **App and platform dependencies**: {app.json, BC version, modules}
- **Repository conventions**: {namespace, affix, ID ranges; no reserved IDs}
- **External dependencies**: {or - None}

## 8. Solution overview and architecture

- **Design summary**: {how components fit together}
- **Key design decisions**: {pattern and reason}
- **Rejected alternatives**: {or - None}
- **Flow**: {Mermaid diagram or - None}

## 9. Data model

### 9.1 Extension objects

#### {Object type} - {proposed name}

- **Base object**: {verified ID and name}
- **Fields**:

| Field   | Type   | Caption   | Properties and relation |
| ------- | ------ | --------- | ----------------------- |
| {field} | {type} | {caption} | {properties}            |

- **Keys, FlowFields, and deletion behavior**: {or - None}
- **Placement**: {or - None}

### 9.2 New tables

#### {Proposed table name}

- **Object ID**: Reserved during implementation
- **Fields**: {same detail as extension fields}
- **Primary and secondary keys / SIFT**: {details}
- **FlowFields / FlowFilters**: {or - None}
- **Relations and deletion behavior**: {details}
- **Properties**: {DataClassification and page links}

### 9.3 Enums

| Proposed enum | Extensible | Values and captions | Default   | Existing base enum |
| ------------- | ---------- | ------------------- | --------- | ------------------ |
| {name}        | {yes/no}   | {values}            | {default} | {or - None}        |

## 10. UI and reports

### Pages and page extensions

| Proposed object | Type / base object | Source table | Placement and fields | Captions and tooltips |
| --------------- | ------------------ | ------------ | -------------------- | --------------------- |
| {name}          | {details}          | {table}      | {details}            | {details}             |

### Actions

| Action | Caption   | Image / promotion | Triggered behavior |
| ------ | --------- | ----------------- | ------------------ |
| {name} | {caption} | {details}         | {behavior}         |

### Reports, notifications, and Role Center

- {details or - None}

## 11. Logic, events, and extensibility

### Codeunits, interfaces, and procedures

#### {Proposed object or procedure}

- **Object ID**: Reserved during implementation when new
- **Responsibility**: {single responsibility}
- **Signature intent**: {parameters and return}
- **Invocation point**: {trigger, event, or caller}
- **Logic**: {ordered behavior}
- **Errors and edge handling**: {details}

### Events

| Kind                   | Publisher / subscriber | Signature or event | Purpose and timing |
| ---------------------- | ---------------------- | ------------------ | ------------------ |
| {published/subscribed} | {object}               | {details}          | {reason}           |

## 12. Setup, permissions, and translations

- **Setup and defaults**: {or - None}
- **Install / upgrade behavior**: {or - None}
- **Permission sets and entitlements**: {required grants; do not create permission-only tests}
- **Data classification**: {details}
- **Labels, captions, and tooltips**: {catalog or - None}
- **Target languages and XLIFF handling**: {languages}

## 13. Integrations and APIs

- **API pages / queries**: {or - None}
- **External endpoints and payloads**: {or - None}
- **Authentication and failure behavior**: {or - None}

## 14. Non-functional and upgrade requirements

- **Performance and data volume**: {keys, SIFT, SetLoadFields, batching}
- **Telemetry and diagnostics**: {or - None}
- **Upgrade and migration**: {compatibility and data steps}
- **Compliance and audit**: {or - None}

## 15. Test scenarios

| Scenario ID                       | Scenario | Given          | When     | Then     | Source |
| --------------------------------- | -------- | -------------- | -------- | -------- | ------ |
| {RequirementId}-{FeatureCode}-001 | {title}  | {precondition} | {action} | {result} | AC-001 |

## 16. Ordered implementation plan

| Step | Objects / files     | Intended behavior | Validation      |
| ---- | ------------------- | ----------------- | --------------- |
| 1    | {concrete location} | {change}          | {focused check} |

## 17. Object inventory

| Type                   |  New | Extended / changed | Complexity driver               |
| ---------------------- | ---: | -----------------: | ------------------------------- |
| Tables                 |  {n} |                {n} | {reason}                        |
| Enums                  |  {n} |                {n} | {reason}                        |
| Pages                  |  {n} |                {n} | {reason}                        |
| Reports                |  {n} |                {n} | {reason}                        |
| Codeunits / interfaces |  {n} |                {n} | {reason}                        |
| Permission sets        |  {n} |                {n} | {reason}                        |
| Tests / scenarios      |  {n} |                {n} | {fixture or environment driver} |

## 18. Self-review

- **Requirement coverage**: {result}
- **Developer readiness**: {result}
- **Consistency and scope integrity**: {result}
- **Feasibility evidence**: {source and symbols checked}
- **Remaining risks**: {or - None}
