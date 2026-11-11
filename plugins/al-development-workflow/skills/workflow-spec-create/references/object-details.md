# Object Details

Write one block per Object catalog row, in catalog order, headed `#### {Ref} {Type} {Name}`. Do not repeat catalog columns. For a `Changed` object, describe only the change and the existing members it touches. When several rows receive an identical change, specify it fully in the first block and reference that block from the others. Include a line or table only when it has content; a block that has nothing to specify means the catalog row is wrong.

## Shared elements

Use these in any block that needs them:

- **Responsibility**: only when the catalog purpose needs more than one clause.
- **Invocation**: triggers, events, actions, or callers that run the new behavior.
- **Procedures**: `Procedure | Access | Signature intent | Behavior`. Describe ordered or branching behavior as a numbered list after the table.
- **Labels and errors**: `Label | Text | Translator comment`, including the meaning of every placeholder.

## Data structures

### enum, enumextension

- **Values**: `Value | Caption | Notes`; notes name interface implementations, consumers that must handle the value, and obsoletion.
- `enum` only: extensibility, default value, implemented interfaces and default implementation.
- Value ordinals are reserved during implementation.

### table, tableextension

- `table` only: caption, data classification, table type, lookup and drill-down pages, and data-per-company when not default.
- **Fields**: `Field | Type | Caption | Properties and relation`, covering table relation, editability, validation, FlowField formula, decimal places, and data classification.
- **Keys**: primary key, secondary keys with their purpose, and SIFT.
- **Triggers and validation**: insert, modify, delete, rename, and field validation behavior, including conditions on `xRec`.
- **Deletion and relations**: cascade, blocking, or snapshot behavior.

## UI and reports

### page, pageextension

- New page: page type, source table, usage category, application area, editability, and card page.
- **Controls**: `Control | Source | Placement | Properties`; placement names the anchor and group, properties cover editability, visibility, caption, and tooltip or its inheritance from the table field.
- **Actions**: `Action | Caption | Placement and promotion | Behavior`.
- Parts, views, and page triggers when they change.

### pagecustomization, profile, profileextension

- Target page or profile, Role Center, caption, included page customizations, and changed visibility or order.

### report, reportextension

- Processing-only or rendered output, and usage category.
- **Dataset**: `Data item or column | Source | Filter or calculation`.
- **Request page**: `Field | Type | Relation and default | Validation`.
- **Layouts**: file path, layout type, and default layout.
- Report, data-item, and request-page trigger behavior.

### controladdin

- Scripts, stylesheets, images, events, procedures, sizing, and hosting page.

## Logic, events, and integrations

### interface

- Procedures with signature intent and the refs of implementing objects.

### codeunit

- Properties when relevant: access, single instance, permissions, event subscriber instance, and table number.
- **Event subscribers**: `Publisher | Event | Behavior and exit condition`; publisher names object type, ID, and app.
- **Published events**: `Event | Signature | Raised when | Contract`; contract states handled-pattern semantics and `var` parameters.

### page (API), query (API)

- API publisher, group, version, entity name, entity set name, and key fields.
- **Exposed fields**: `JSON name | Source | Read or write | Validation`.
- Write behavior, bound actions, and error responses.

### query

- Query type, data items with links and filters, columns with aggregation, ordering, and consumer.

### xmlport

- Direction, format, and encoding.
- **Schema**: `Element | Source | Required | Mapping`.
- Error and partial-import behavior.

### dotnet

- Assembly, type, on-premises target, and calling objects.

## Cross-cutting

### permissionset, permissionsetextension

- Assignability, included permission sets, and the target set of an extension.
- **Permissions**: `Object | RIMDX | Reason`.

### entitlement

- Entitlement type, identifiers, and object entitlements.

### codeunit (Install), codeunit (Upgrade)

- Triggers used, per company or per database.
- Upgrade tag and its registration.
- Ordered data steps, idempotency, and behavior on rerun or partial data.

## Tests

### codeunit (Test library)

- Fixture and helper procedures, and reused existing libraries.

### codeunit (Test)

- Scenario IDs automated by the codeunit.
- Handlers with their expected interaction.
- Test permissions and transaction model when not default.
