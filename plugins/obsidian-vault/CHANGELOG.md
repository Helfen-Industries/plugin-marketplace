# Changelog

All notable changes to this plugin are documented here.

## [0.3.0] - Unreleased

### Added

- Scaffold workflow (`vault-scaffold-create`) with the script `New-VaultScaffold.ps1`: creates a new customer (`10-Kunden/<Name>/`), internal project (`20-Projekte/<Name>/`), or Teilprojekt (`<Ort>/Teilprojekte/<Name>.md`) with every subfolder and its `.gitkeep`, the fact sheet or start page from the vault's template, the `Kunden:` or `Projekte:` list check for `AGENTS.md`, and, on request, the `teilprojekt` tag on existing notes. Existing folders and files are never overwritten.
- Teilprojekte: the optional frontmatter list `teilprojekt` and the note type `teilprojekt` for a delimited part of a customer or project with its own contacts or repository. A start page embeds the vault's shared view `99-System/Bases/Teilprojekt.base`, which lists all notes that name the Teilprojekt.

### Changed

- `Test-VaultNote.ps1` knows the type `teilprojekt` (folder `Teilprojekte/`, status `aktiv`, `ruhend`, `abgeschlossen`, no comma in the name) and checks that every `teilprojekt` value matches a start page of the same customer or project exactly; unknown values are errors under `10-Kunden/` and `20-Projekte/` and warnings in `00-Inbox/`.
- `Get-VaultCustomerContext.ps1` lists the Teilprojekte, returns each note's `teilprojekt`, resolves a Teilprojekt by `-Teilprojekt`, by name or alias as `-Customer`, or by a repository path in its start page, and then returns that Teilprojekt's notes plus the notes without `teilprojekt`. `vault-customer-context` adds a Teilprojekte section to the brief.
- Task, meeting, concept, decision, process, and maintenance workflows set or propose `teilprojekt` only on evidence and never guess it. `vault-profile-update` delegates the creation of new customers and projects to `vault-scaffold-create`.
- System files include `99-System/Bases/`.

## [0.2.0] - Unreleased

### Added

- Appointment workflow (`vault-appointment-create`): creates an appointment in the user's Outlook calendar from a vault note or a direct request through the vault's `99-System/Skripte/Export-Termin.ps1` and the Power Automate flow `Vault-Terminexport`. It shows a `-WhatIf` preview first, sends invitations only after explicit confirmation of the listed attendees, never invents dates, durations, or attendee addresses, adds the `obsidian://` note link only to appointments without attendees, checks the flow result with `-Status`, and after confirmation appends the returned line under `## Termine` of the source note.

## [0.1.0] - Unreleased

### Added

- Plugin README with the working concept for a personal Obsidian vault: knowledge and delivery layers, vault contract, customer resolution, change gates, Git handling, and concept-to-spec alignment.
- Read-only customer context brief (`vault-customer-context`) with deterministic customer resolution by name, alias, repository path, Git remote, or DevOps project.
- Shared write discipline (`vault-note-write`) with search-before-create, template handling, change gates for fact sheets and decided ADRs, vault check, scaffold-only local commits, and push only on request.
- Workflows for meeting notes, concepts in technical-spec Part A structure, ADRs, customer fact sheets, process documentation, and vault maintenance with inbox triage.
- Scripts: `Get-VaultCustomerContext.ps1`, `Test-VaultNote.ps1`, and the read-only repository scanner `Get-RepoFacts.ps1`.
- Task workflow (`vault-task-create`): tasks for the vault's task board from a mail pasted in chat, from an Azure DevOps work item through `ado-remote-mcp` or the vault's `Import-DevOpsAufgabe.ps1`, or by converting an imported inbox mail (`## Inhalt` becomes `## Auftrag`, `## Anhänge` stays); every new task starts with `status: inbox`.

### Changed

- Vault structure: numbered folders `00-Inbox`, `10-Kunden`, `20-Projekte`, `30-Agents`, `80-Daily`, `90-Templates`, and `99-System`; the vault root is recognized by `AGENTS.md` and `10-Kunden/`.
- `Test-VaultNote.ps1` checks customers and internal projects, the types `aufgabe`, `problem`, `session`, `katalog`, `anweisung`, and `learning` with their folders and status values, task fields (`quelle`, `faellig`, `start`/`ende` as `YYYY-MM-DDTHH:mm`, `mail-*`, `devops`, `devops-link`, `## Auftrag`), `projekt` under `20-Projekte`, and never `kunde` together with `projekt`. Unknown source values may be `offen`. System files (`AGENTS.md`, `Dashboard.md`, `Task Board.base`, `90-Templates/`, `99-System/`, `Excalidraw/`) are skipped.
- Git: notes are excluded by the vault's `.gitignore` and are never committed or forced with `git add -f`; workflows commit only scaffold they create and report `nicht versioniert` for notes.
- `vault-customer-context` resolves projects as well, lists open tasks (`status` other than `archiv`), and lists matching appointments of the next 7 days from the generated Outlook calendar with subject and time only.
- `vault-profile-update` creates and refreshes project fact sheets from `90-Templates/Projektsteckbrief.md`, creates the subfolders with `.gitkeep`, and proposes adding a new name to the lists in `AGENTS.md`.
- `vault-maintenance` ignores system and generated files, reviews imported mails in `00-Inbox/` as task, knowledge, or deletion for customers and projects, and reports tasks without a valid status.
- Meeting, concept, and decision workflows accept internal projects; processes stay customer-only as defined in `AGENTS.md`.
