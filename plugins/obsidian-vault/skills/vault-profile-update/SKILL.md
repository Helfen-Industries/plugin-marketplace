---
name: vault-profile-update
description: Create or refresh a customer's or internal project's fact sheet (00-Steckbrief.md) in the Obsidian vault from verifiable sources only - local repositories read-only (app.json, BC build artifacts, apps and dependencies, Git remotes, plans folders), Azure DevOps projects, dated meeting notes, and explicit user statements - and check off answered open questions. Use when adding a new customer or project to the vault, when the user says "Steckbrief anlegen", "Projektsteckbrief anlegen", "Steckbrief pflegen", or "Steckbrief aktualisieren", after BC upgrades or new apps, or when the context brief reports stale or contradictory facts.
argument-hint: "<customer or project> [repository folder] [new facts with source]"
user-invocable: true
---

# Update Customer Profile

Every table row needs a source; anything unknown stays `offen`. An interpretation is not a fact.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Establish the area, the folder, and the mode. The area is customer (`10-Kunden/`) or project (`20-Projekte/`); `AGENTS.md` defines projects as own undertakings without customer assignment, so ask when the request does not make it clear. The mode is new, refresh, or record supplied facts and answers. For a new entry:
   - take the folder name from the user;
   - create the structure with [Create Vault Scaffold](../vault-scaffold-create/SKILL.md): the folder, every subfolder that `AGENTS.md` lists under `10-Kunden/<Kunde>/` or `20-Projekte/<Projekt>/` (including `Teilprojekte/`) with an empty `.gitkeep`, and `<Ort>/00-Steckbrief.md` from `90-Templates/Steckbrief.md` for a customer or `90-Templates/Projektsteckbrief.md` for a project, with `kunde` or `projekt` set to the folder name; that skill also proposes the entry in the customer or project list of `AGENTS.md` and changes that file only after confirmation.
   - Done when the folder, area, and mode are known and a new entry has its fact sheet and subfolders.
2. Collect evidence without changing any source:
   - **Repositories:** run [Get-RepoFacts.ps1](scripts/Get-RepoFacts.ps1) with `-Path` set to the repository paths in the fact sheet or the folder the user names; separate several paths with `;`. It reads the local state of the remote default branch without fetching; say so in the source. Its app and build facts apply to Business Central repositories; for other projects use its remote, default branch, and last commit, and read further files from the same ref read-only.
   - **Azure DevOps:** when tools are available and the fact sheet has an `Azure DevOps` table, list the organization's projects and descriptions.
   - **Meetings** since the fact sheet's `stand`, cited as `Meeting YYYY-MM-DD`.
   - **User statements**, cited as `Angabe <Name>, YYYY-MM-DD`.
   - Done when every candidate value has a source or is `offen`.
3. Build a change list against the current fact sheet with the classes new, changed, reconfirmed, and not verifiable. Never remove a fact only because its source was unavailable; mark it `nicht geprüft`. Keep `aliases` complete with company or product names, short names, DevOps project names, and repository names, and keep every repository link and local path in the repositories table, because the resolution of customers and projects matches on them. Done when every row in the change list has a source.
4. Present the change list. Write a new fact sheet the user asked for directly; changes to an existing fact sheet pass the change gate. Done when the list is confirmed or declined.
5. Write through the write discipline. Set `stand` to the review date, and check off answered open questions with answer and source. Never copy SAS tokens, secrets, or download URLs from build settings. The fact sheet stays local; only new `.gitkeep` files and a confirmed `AGENTS.md` change are committed. Done when the write discipline reports `passed` and its commit state.

## Output

Return the fact-sheet link, the created folders, the applied changes by class, the remaining open questions, and the commit state.
