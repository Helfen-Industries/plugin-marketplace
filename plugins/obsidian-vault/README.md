# Obsidian Vault

Agent workflows for a personal Obsidian knowledge vault with one folder per customer and per internal project: fact sheets, decisions (ADRs), concepts, processes, meeting notes, and tasks for the task board that GitHub Copilot can read and maintain.

## Get Started

Register the marketplace and install the plugin:

```powershell
copilot plugin marketplace add Helfen-Industries/plugin-marketplace
copilot plugin install obsidian-vault@helfen-agent-marketplace
copilot plugin list
```

Prerequisites:

- A vault at `C:\Dev\Knowledge`, or a path you name per request, containing `AGENTS.md` and `10-Kunden/`. The vault's `AGENTS.md` defines its structure.
- Windows PowerShell 5.1 or PowerShell 7 and Git for the bundled scripts.
- Optional: Azure DevOps tools (`ado-remote-mcp`) to read work items and projects; alternatively the vault's `99-System/Skripte/Import-DevOpsAufgabe.ps1` with `az login`.
- Optional: the generated Outlook calendar `99-System/Kalender/outlook/outlook.ics` for upcoming appointments.
- Optional: the vault's `99-System/Skripte/Export-Termin.ps1` and the Power Automate flow `Vault-Terminexport` (setup in the vault's `99-System/Skripte/README.md`) to create Outlook appointments.

Load the context of the customer or project whose repository is open:

```text
/obsidian-vault:vault-customer-context 15347
```

## Concept

### Two layers

| Layer | Holds | Location | Source of truth for |
| --- | --- | --- | --- |
| Knowledge | Fact sheet, decisions, concepts, processes, meetings, tasks | Vault `10-Kunden/<Kunde>/` or `20-Projekte/<Projekt>/` | What the customer or project is, wants, and agreed |
| Delivery | AL code, technical specification, tests | Customer repository, `plans/` | How it is built |

The vault links to repository artifacts and never copies them. A concept stores the absolute spec path in `spec`.

### Vault contract

The vault's `AGENTS.md` is the single source of truth for folders, filenames, frontmatter, task fields, todo syntax, diagram formats, and links. Skills read it at run time and contain only procedures and gates, so convention changes happen in one place. `Test-VaultNote.ps1` is the executable check of that contract; when both disagree, `AGENTS.md` wins and the script is updated. System files are never checked: `AGENTS.md`, `Dashboard.md`, `Task Board.base`, `90-Templates/`, `99-System/` with the generated calendar, and `Excalidraw/`.

### Customer and project resolution

`Get-VaultCustomerContext.ps1` maps a request to exactly one fact sheet under `10-Kunden/` or `20-Projekte/`, in this order:

1. explicit name: folder name, `kunde` or `projekt`, or `aliases`, exact before partial;
2. repository path listed in the fact sheet, including subfolders and the parent folder;
3. Git remote URL listed in the fact sheet (HTTPS with or without user, SSH);
4. DevOps project or repository name listed in `aliases`.

Ambiguous results are asked, unresolved notes go to `00-Inbox/` with the open question „Kunde oder Projekt zuordnen“. A note carries `kunde` or `projekt`, never both. The fact sheet's `aliases` and repositories table therefore drive resolution and are kept current by `vault-profile-update`.

### Tasks and calendar

Task notes (`typ: aufgabe`) in `<Ort>/Aufgaben/` feed the vault's task board. `vault-task-create` creates them from a mail pasted in chat, from an Azure DevOps work item, or by converting an imported mail from `00-Inbox/`. Every new task starts with `status: inbox`; you move it on the board. `vault-maintenance` reviews imported mails as task, knowledge, or deletion and reports tasks without a valid status.

`vault-customer-context` lists open tasks and the appointments of the next 7 days whose subject or location names the customer or project. It reads the generated calendar only through its script and reports subject and time, never attendees, organizer, location, or description.

`vault-appointment-create` works in the other direction: it creates an appointment in the user's Outlook calendar from a note or a direct request. Because the new Outlook has no COM and Microsoft Graph needs admin consent, the vault's `Export-Termin.ps1` writes a request file to OneDrive and the Power Automate flow `Vault-Terminexport` creates the event and writes back its Outlook link. Every appointment is previewed first; attendees receive invitations immediately, so requests with attendees need explicit confirmation of the preview. A link to the note appears only in appointments without attendees, and after confirmation the source note gets a line under `## Termine`.

### Safety and gates

- Customer repositories and everything outside the vault are read-only; `Get-RepoFacts.ps1` never fetches or checks out.
- New notes are created only on request. Changing facts in a fact sheet, changing a decided ADR, and moving, renaming, or deleting notes require confirmation of the visible change.
- Facts need a source; unknown values stay `offen`. Secrets, SAS tokens, and download links are never written.
- The vault repository versions only scaffold and setup. Notes in `00-Inbox/`, `10-Kunden/`, `20-Projekte/`, `30-Agents/`, `80-Daily/`, and `99-System/Kalender/` are excluded by the vault's `.gitignore`; skills never commit them and never force them with `git add -f`. They commit locally only scaffold they create, such as the `.gitkeep` files of a new customer or a confirmed `AGENTS.md` change. Pushing needs explicit confirmation each time.

### Concepts and specifications

The concept template mirrors Part A of the `al-development-workflow` technical specification:

| Concept section | Spec Part A section |
| --- | --- |
| Zusammenfassung und Intention | 1. Summary |
| Ausgangslage und Kontext | 2. Initial situation and context |
| Soll-Ablauf | 3. Target process |
| Scope | 4. Scope |
| Top-Entscheidungen | 5. Key decisions |

The concept is the agreed business view; the specification adds the technical design. `vault-concept-create` reports differences between both without editing the repository.

### Integration with AL development

`workflow-work-package-begin` in `al-development-workflow` applies `vault-customer-context` when this plugin is installed. The brief becomes labeled context for analysis, exploration, and clarification: decisions in force constrain the solution and conflicts become clarification items, but vault content never replaces the requirement source. Without this plugin, the AL workflow runs unchanged.

## Contents

| Skill | Role | Purpose |
| --- | --- | --- |
| `vault-customer-context` | Public, read-only | Resolve the customer or project and return a linked brief of facts, decisions in force, concepts, processes, open tasks, appointments of the next 7 days, and open items |
| `vault-task-create` | Public driver | Create a task with status `inbox` from a mail in chat or an Azure DevOps work item, or convert an imported inbox mail into a task |
| `vault-appointment-create` | Public driver | Create an Outlook appointment from a note or request through the vault's Power Automate flow, with preview, confirmed invitations, status check, and a `## Termine` line in the note |
| `vault-meeting-note` | Public driver | Turn raw notes or transcripts into a meeting note with decisions, questions, and todos, then propose follow-ups |
| `vault-concept-create` | Public driver | Create or revise a concept in Part A structure with a Mermaid target process |
| `vault-decision-record` | Public driver | Create, supersede, accept, or reject ADRs |
| `vault-profile-update` | Public driver | Create or refresh a customer or project fact sheet from repositories, DevOps, meetings, and statements |
| `vault-process-document` | Public driver | Document a customer's Ist or Soll processes with Mermaid swimlanes |
| `vault-maintenance` | Public driver | Check the vault against its contract, report tasks without valid status, and triage `00-Inbox/` including imported mails |
| `vault-note-write` | Hidden primitive | Shared write discipline used by every writing workflow |

| Script | Purpose |
| --- | --- |
| `vault-customer-context/scripts/Get-VaultCustomerContext.ps1` | Customer and project resolution and context manifest with open tasks and matching appointments as JSON |
| `vault-note-write/scripts/Test-VaultNote.ps1` | Contract check for folders, types, frontmatter, task fields, filenames, ADR numbers, checkboxes, template remnants, and links |
| `vault-profile-update/scripts/Get-RepoFacts.ps1` | Read-only scan of app.json, build artifacts, remotes, and plans folders |

## Usage

```text
/obsidian-vault:vault-task-create Aufgabe für Assmann aus dieser Mail: <Mailtext>
/obsidian-vault:vault-task-create AB#15347 für Spacemann
/obsidian-vault:vault-task-create Inbox-Mail "2026-11-13 Assmann Artikelstamm von BC an FLS" als Aufgabe
/obsidian-vault:vault-appointment-create Termin für Aufgabe "2026-11-16 Mapping prüfen" (Assmann) am 20.11.2026 9–10:30 Uhr
/obsidian-vault:vault-appointment-create Terminstatus prüfen
/obsidian-vault:vault-meeting-note Spacemann, heute, Abstimmung Kommissionierung: <Notizen>
/obsidian-vault:vault-concept-create Spacemann 15347 Produktionskommissionierung mit Tourdatum
/obsidian-vault:vault-decision-record Assmann: Wir nutzen die COSMO-Seriennummernlogik (Meeting 2026-11-10)
/obsidian-vault:vault-profile-update Assmann aus den Repos aktualisieren
/obsidian-vault:vault-profile-update Projektsteckbrief Plugin-Marketplace anlegen
/obsidian-vault:vault-process-document dtH Tiemann Verkauf - Auftragsabwicklung ist
/obsidian-vault:vault-maintenance Inbox aufräumen
```

Every workflow answers in the user's language and ends with the written note links, the vault check result, the commit state (`nicht versioniert` for notes), and the push state.

See [CHANGELOG.md](CHANGELOG.md) for release history.
