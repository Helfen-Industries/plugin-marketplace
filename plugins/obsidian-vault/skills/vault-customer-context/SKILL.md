---
name: vault-customer-context
description: Load verified customer knowledge from the personal Obsidian vault (C:\Dev\Knowledge) - fact sheet, decisions in force, concepts, processes, and open items, optionally focused on one Azure DevOps work item - as a short linked brief. Use when the user asks for "Kundenkontext laden", customer context, or what was decided or agreed for a customer; when starting or analyzing work in a customer repository under C:\Dev\Customers; and before writing a concept, meeting note, decision, or specification for a customer. Read-only.
argument-hint: "[customer name or repository path] [work item ID]"
user-invocable: true
---

# Load Customer Context

Read-only: never change the vault or a repository in this workflow.

## Process

1. Run [Get-VaultCustomerContext.ps1](scripts/Get-VaultCustomerContext.ps1). Pass `-Customer` when the user or caller names a customer, otherwise `-Path` with the current repository or workspace folder. Add `-WorkItem` with the requirement-source ID when one is known. Handle `status`:
   - `resolved`: continue.
   - `ambiguous`: ask the user once to choose one of the `candidates`, then rerun with `-Customer`.
   - `unresolved`: report the tried keys (`query.path`, `query.gitTopLevel`, `query.remote`, `query.customer`) and end with `Kein Kundenkontext`. Suggest adding the repository link and local path or the DevOps project to the fact sheet with [Update Customer Profile](../vault-profile-update/SKILL.md).
   - `vault-not-found`: end with `Kein Kundenkontext: Vault nicht gefunden`.
   - Done when exactly one customer is selected or a terminal state is reported.
2. Read selectively from the returned manifest:
   - the fact sheet completely;
   - decisions with `active: true`: their `## Entscheidung` section, plus `## Konsequenzen` when `matchesWorkItem`; read replaced or rejected ADRs only to explain a replacement chain;
   - concepts with `matchesWorkItem`: completely; other concepts and all processes: title and status from the manifest, unless a title matches the request topic;
   - meetings: `openTodos` and `openQuestions` from the manifest; the full note only when `matchesWorkItem`.
   - Done when every manifest entry is either read or summarized from its metadata.
3. Compose the brief below. Link every statement to its note. When repository evidence contradicts the fact sheet, report both values; the repository is authoritative for code facts. Do not edit the vault; propose [Update Customer Profile](../vault-profile-update/SKILL.md) instead. Flag a fact sheet whose `ageDays` exceeds 90. Done when every brief section has content or `keine`.

```markdown
## Kundenkontext: <Kunde>
Quelle: [[Kunden/<Kunde>/00-Steckbrief|Steckbrief]] (Stand <stand>), zugeordnet über <matchedBy>

### Fakten
- at most 8 facts relevant to the request: BC version and localization, operation mode, own apps and product apps of the repository or topic

### Geltende Entscheidungen
- [[ADR-NNNN Titel]] (<status>): <decision sentence>

### Konzepte und Prozesse
- [[<Konzept>]] (<status>, Spec: <path or keine>): <one line>
- other concepts and processes as a title list

### Offene Punkte
- open questions of the fact sheet and concepts; open todos and questions of meetings with their date

### Lücken
- for example: no concept for AB#<id>, fact sheet older than 90 days, contradiction with the repository
```

## Rules for consumers

- Vault content is context, not a requirement. Never derive acceptance criteria from it.
- A decision in force constrains the solution. A conflict between it and a requirement is a clarification item.
- Open questions in the vault are candidates for clarification, not answers.

## Output

The brief and the state `Kundenkontext geladen` or `Kein Kundenkontext`, in the user's language.
