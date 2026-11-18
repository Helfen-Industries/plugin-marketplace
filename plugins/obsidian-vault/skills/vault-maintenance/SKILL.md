---
name: vault-maintenance
description: Check and tidy the Obsidian knowledge vault - validate frontmatter, filenames, ADR numbering, task status and fields, checkbox placement, template remnants, and links against the vault's AGENTS.md, report stale fact sheets and forgotten open items, and triage notes and imported mails in 00-Inbox to customers or projects as task, knowledge, or deletion. Use when the user asks to "Inbox aufräumen", "Mails sichten", "Vault prüfen", clean up, check, or tidy the knowledge base, asks which tasks have no valid status, or after many manual edits in Obsidian.
argument-hint: "[prüfen | aufräumen] [customer, project, or folder]"
user-invocable: true
---

# Maintain Vault

Report only by default. Change notes only when the user asked to tidy up or confirms a proposed fix, and apply [Write Vault Note](../vault-note-write/SKILL.md) for every change.

System and generated files are never findings: `AGENTS.md`, `Dashboard.md`, `.base` files such as `Task Board.base` and everything under `99-System/Bases/`, `90-Templates/`, `99-System/` including the calendar in `99-System/Kalender/`, `Excalidraw/`, and `.gitkeep`. Notes are not versioned in Git, so uncommitted or ignored notes are never findings either.

## Process

1. Run [Test-VaultNote.ps1](../vault-note-write/scripts/Test-VaultNote.ps1) for the whole vault, or with `-Path` for the requested `10-Kunden/<Kunde>` or `20-Projekte/<Projekt>` folder. Done when its JSON result is available.
2. Report the findings grouped by customer or project, then `00-Inbox/`, `30-Agents/`, and `80-Daily/`: errors, warnings, info (fact sheets older than 90 days, open items in notes older than 30 days), and every note in `00-Inbox/`. List tasks (`typ: aufgabe`) with a `status` finding as their own group, because the task board shows them only under „Uncategorized“. When `AGENTS.md` and the script disagree, `AGENTS.md` wins; report the drift. Done when every finding appears exactly once.
3. Propose a fix for each finding, split into mechanical fixes (frontmatter value, missing tag, filename date, a `teilprojekt` value that differs from a start page only in case) and content decisions (customer or project assignment, move, merge, old open items, task status, a `teilprojekt` value without any start page: create the Teilprojekt with [Create Vault Scaffold](../vault-scaffold-create/SKILL.md) or correct the value). Never close a todo or question and never choose a task status on your own; propose done, still open, or obsolete, and leave the status choice to the user. Done when every finding has a proposal or `keine Aktion` with a reason.
4. Triage `00-Inbox/`. Determine the customer or project through the resolver in [Load Customer Context](../vault-customer-context/SKILL.md) using a prefilled `kunde` or `projekt`, then names and aliases from the note; for mail notes (`quelle: mail`) also `mail-betreff` and `mail-von`. Then propose exactly one outcome per note:
   - **Mail as task:** apply [Create Task](../vault-task-create/SKILL.md) to convert the note.
   - **Mail or note as knowledge:** set the matching `typ` (for example `problem`, `meeting`, `konzept`) and move it to that type's folder under `<Ort>/`; `quelle` and `mail-*` stay as source. When the note clearly belongs to a Teilprojekt of that customer or project (name, alias, or repository named in the text), propose `teilprojekt: [<Name>]` with it; never guess. When no type with a folder fits, leave the note in `00-Inbox/` and report it; never place a `notiz` directly under `<Ort>/`.
   - **Mail that is only an appointment or already done:** delete the note; the original stays in Outlook.
   - **Other note:** move to its type's folder, merge into an existing note, or delete an empty note.
   - Every move, merge, and deletion needs confirmation; mails are classified only on the user's explicit request. Leave an unassignable note in `00-Inbox/` with „Kunde oder Projekt zuordnen“ under `## Offene Fragen`.
   - Done when every `00-Inbox/` note has a confirmed outcome, a declined proposal, or that question.
5. Apply the confirmed fixes and rerun the check. Done when the check reports `passed` or each remaining finding is listed with its reason.

## Output

Return finding counts before and after, the applied changes, and the remaining findings.
