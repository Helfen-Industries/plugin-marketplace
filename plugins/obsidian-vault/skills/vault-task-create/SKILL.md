---
name: vault-task-create
description: Create a task note (typ aufgabe) for the task board of the personal Obsidian vault (C:\Dev\Knowledge) - from a mail text pasted in chat, from an Azure DevOps work item ID or URL, or by converting an imported mail in 00-Inbox into a task - always with status inbox and filed under the customer's or project's Aufgaben folder. Use when the user says "Aufgabe anlegen", "Aufgabe aus dieser Mail", "Work Item als Aufgabe übernehmen", "aus der Inbox-Mail eine Aufgabe machen", pastes a mail to file in the vault, or when a meeting note or inbox triage produces a task with its own content.
argument-hint: "<mail text | work item ID or URL | 00-Inbox note> [customer or project]"
user-invocable: true
---

# Create Task

Task notes feed the task board; small todos inside a note stay checkbox lines and are out of scope. The vault's `AGENTS.md` section „Aufgaben“ defines filename, fields, the `> [!info] Quelle` callout, `## Auftrag`, `## Anhänge`, and the inbox review of mails.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change. These rules hold for every branch:

- **Status:** every created or converted task gets `status: inbox`, also when the user asks for `heute` or `geplant`; the user moves it on the board. Never set `start`, `ende`, or `erledigt`.
- **No invention:** `faellig` only from the work item's due date or a calendar date the source states as deadline; relative wording such as „bis Freitag“ becomes an open question. Ask once for a missing sender, mail date, or subject; whatever is still unknown is written as `offen`. A pasted mail rarely contains its Internet Message ID, so `mail-id` is then `offen`.
- **No copies:** from a mail only the newest message without quoted history; from a work item only title, type, state, and acceptance criteria, never the description; attachments only as a name list.

## Process

1. Classify the source as exactly one branch:
   - **Mail text:** a mail pasted in chat. When the user only wants it filed and does not ask for a task, create an inbox note instead: `typ: notiz`, `quelle: mail`, the `mail-*` fields, `tags: [notiz, mail]`, the source callout, `## Inhalt`, and `## Anhänge`, in `00-Inbox/` per `AGENTS.md`; skip step 4.
   - **Work item:** an Azure DevOps ID or URL.
   - **Inbox mail:** an existing note in `00-Inbox/` with `quelle: mail`.
   - **Meeting or manual:** a task described by the user or a meeting note, with `quelle: meeting` or `manuell`.
   - Done when one branch is selected.
2. Resolve `<Ort>` and rule out duplicates:
   - Resolve the customer or project through the write discipline from the name the user gives, a prefilled `kunde` or `projekt`, or names and aliases in subject, sender, or work item project. When nothing resolves uniquely, the note goes to `00-Inbox/` with an empty `kunde:` and „Kunde oder Projekt zuordnen“ under `## Offene Fragen`.
   - Search the whole vault: a note with the same `mail-id` (unless `offen`), a `typ: aufgabe` note with the same ID in `devops`, or a task with the same `mail-betreff` and `mail-von`. When one exists, report its link and create nothing.
   - **Teilprojekt:** when the user or the source names a Teilprojekt of the selected customer or project (`<Ort>/Teilprojekte/<Name>.md`), or the work item's repository or title names it unambiguously, set `teilprojekt: [<Name>]`; otherwise leave `teilprojekt: []`. Never guess it. For the vault's `Import-DevOpsAufgabe.ps1` pass `-Teilprojekt <Name>`.
   - Done when one target folder is selected and no duplicate exists, or the existing note is reported.
3. Collect the source fields:
   - **Mail text:** `mail-von` (address), `mail-datum` as `YYYY-MM-DDTHH:mm`, `mail-betreff`, and `mail-id` from the pasted headers; `## Auftrag` is the newest message; attachment names go to `## Anhänge`.
   - **Work item:** read the item itself, not its parent, with the read-only Work Item Tracking tool of `ado-remote-mcp` (for example `wit_work_item`). Discover the tool and handle connection, authentication, and access failures as the `workflow-azure-devops-work-item-get` skill of `al-development-workflow` describes; never change the work item. Take title, type, state, organization, project, link, due date, and acceptance criteria. When the server is unavailable, offer `99-System/Skripte/Import-DevOpsAufgabe.ps1` as the alternative: run it from the vault root with the URL, or with `-Id` and `-Kunde <customer or project folder>`, first with `-WhatIf`, then without; it creates the note itself under the same rules, and step 4 is skipped. It needs `az login`; report its error output unchanged.
   - **Inbox mail:** read the note; its `quelle`, `mail-*`, `datum`, callout, and `## Anhänge` stay as they are.
   - **Meeting or manual:** the callout names the meeting as wikilink, or who asked and when.
   - Done when every mandatory task field from `AGENTS.md` has a value or `offen`.
4. Compose the note:
   - **New task** from `90-Templates/Aufgabe.md`: `datum` is today as creation date; filename `YYYY-MM-DD <Titel>.md`, for a work item `YYYY-MM-DD <ID> <Titel>.md` with heading `# <ID> <Titel>`. For a work item set `devops: [<ID>]` and `devops-link`, put `AB#<ID>` with link, type, and state at import into the callout, and title plus acceptance criteria under `## Auftrag`. For a mail with attachments add `## Anhänge` after `## Auftrag`.
   - **Inbox mail conversion:** set `typ: aufgabe`, `status: inbox`, replace `notiz` in `tags` with `aufgabe`, set `kunde` or `projekt`, rename `## Inhalt` to `## Auftrag`, keep `## Anhänge` unchanged, add the missing template sections in template order, and check off „Kunde oder Projekt zuordnen“ with the chosen place. The target is `<Ort>/Aufgaben/` with the same filename. Moving passes the change gate: show the frontmatter before/after, the section changes, and the target path, then wait for confirmation.
   - Done when the note matches the template structure and a conversion is confirmed.
5. Write through the write discipline; for a conversion write the converted content to the target path and remove the inbox note in the same step. Done when the write discipline reports `passed` for the note and its commit state, which is `nicht versioniert` for notes.

## Output

Return the note link, the place, `status: inbox` for a task, the fields written as `offen`, a reported duplicate if any, the check result, and the commit state.
