---
name: vault-customer-context
description: Load verified customer or project knowledge from the personal Obsidian vault (C:\Dev\Knowledge) - fact sheet, Teilprojekte, decisions in force, concepts, processes, open items, open tasks, and the customer's or project's Outlook appointments of the next 7 days - optionally focused on one Teilprojekt or one Azure DevOps work item, as a short linked brief. Use when the user asks for "Kundenkontext laden", "Projektkontext", "Kontext für das Teilprojekt FLS", customer or project context, open tasks, upcoming appointments, or what was decided or agreed for a customer, internal project, or Teilprojekt; when starting or analyzing work in a customer repository under C:\Dev\Customers or a project repository; and before writing a concept, meeting note, decision, task, or specification. Read-only.
argument-hint: "[customer, project, or repository path] [work item ID] [Teilprojekt]"
user-invocable: true
---

# Load Customer Context

Read-only: never change the vault, the calendar, or a repository in this workflow. The same workflow serves customers (`10-Kunden/`) and internal projects (`20-Projekte/`).

## Process

1. Run [Get-VaultCustomerContext.ps1](scripts/Get-VaultCustomerContext.ps1). Pass `-Customer` with the customer or project name when the user or caller names one, otherwise `-Path` with the current repository or workspace folder. Add `-WorkItem` with the requirement-source ID when one is known, and `-Teilprojekt` when the user names a Teilprojekt of the customer. Handle `status`:
   - `resolved`: continue with `customer.name`, `customer.bereich` (`kunde` or `projekt`), and `customer.ort`. When the customer or project has Teilprojekte, `teilprojekte` lists their start pages. `teilprojekt` is set when the request names one (`-Teilprojekt`, a Teilprojekt name or alias as `-Customer`, or a repository path listed in a start page); then the manifest keeps the notes of that Teilprojekt and the notes without `teilprojekt`, which apply to the whole customer or project, and drops the notes of other Teilprojekte. `teilprojekt.found: false` means the requested name has no start page. Every note carries its `teilprojekt` list.
   - `ambiguous`: ask the user once to choose one of the `candidates`, then rerun with `-Customer`.
   - `unresolved`: report the tried keys (`query.path`, `query.gitTopLevel`, `query.remote`, `query.customer`) and end with `Kein Kundenkontext`. Suggest adding the repository link and local path or the DevOps project to the fact sheet with [Update Customer Profile](../vault-profile-update/SKILL.md).
   - `vault-not-found`: end with `Kein Kundenkontext: Vault nicht gefunden`.
   - Done when exactly one customer or project is selected or a terminal state is reported.
2. Read selectively from the returned manifest:
   - the fact sheet completely, and the start page of the focused Teilprojekt completely (purpose, contacts, repositories); for other Teilprojekte only name and status from the manifest;
   - decisions with `active: true`: their `## Entscheidung` section, plus `## Konsequenzen` when `matchesWorkItem`; read replaced or rejected ADRs only to explain a replacement chain;
   - concepts with `matchesWorkItem`: completely; other concepts and all processes: title and status from the manifest, unless a title matches the request topic;
   - meetings: `openTodos` and `openQuestions` from the manifest; the full note only when `matchesWorkItem`;
   - tasks (`typ: aufgabe`, every status except `archiv`): title, status, `faellig`, and `start` from the manifest; the full note only when `matchesWorkItem`;
   - appointments: only `betreff`, `beginn`, `ende`, and `ganztaegig` from the manifest. Never open `outlook.ics` directly and never report attendees, organizer, location, or description.
   - Done when every manifest entry is either read or summarized from its metadata.
3. Compose the brief below. Link every statement to its note. When repository evidence contradicts the fact sheet, report both values; the repository is authoritative for code facts. Do not edit the vault; propose [Update Customer Profile](../vault-profile-update/SKILL.md) instead. Flag a fact sheet whose `ageDays` exceeds 90 and every task with `statusValid: false`. Done when every brief section has content or `keine`.

```markdown
## Kontext: <Name> (Kunde | Projekt)
Quelle: [[<ort>/00-Steckbrief|Steckbrief]] (Stand <stand>), zugeordnet über <matchedBy>

### Teilprojekte
- focus: [[<ort>/Teilprojekte/<Name>|<Name>]] (<status>, zugeordnet über <teilprojekt.matchedBy>): purpose, contacts, repository in one line each
- other Teilprojekte as a name and status list; `keine` when `teilprojekte` is empty

### Fakten
- at most 8 facts relevant to the request: for a customer BC version and localization, operation mode, own apps and product apps of the repository or topic; for a project purpose, kind, components, and repositories

### Geltende Entscheidungen
- [[ADR-NNNN Titel]] (<status>): <decision sentence>

### Konzepte und Prozesse
- [[<Konzept>]] (<status>, Spec: <path or keine>): <one line>
- other concepts and processes as a title list

### Offene Aufgaben
- [[<Aufgabe>]] (<status>, fällig <faellig>, Zeitblock <start>): due tasks first

### Termine (nächste 7 Tage)
- <beginn>–<ende>: <betreff>
- Kalenderstand <calendar.updated>; `keine (Kalender nicht vorhanden)` when `calendar.state` is `nicht vorhanden`

### Offene Punkte
- open questions of the fact sheet and concepts; open todos and questions of meetings with their date

### Lücken
- for example: no concept for AB#<id>, fact sheet older than 90 days, task without valid status, contradiction with the repository
```

## Rules for consumers

- Vault content is context, not a requirement. Never derive acceptance criteria from it.
- A decision in force constrains the solution. A conflict between it and a requirement is a clarification item.
- Open questions and open tasks in the vault are candidates for clarification, not answers.

## Output

The brief and the state `Kundenkontext geladen` or `Kein Kundenkontext`, in the user's language.
