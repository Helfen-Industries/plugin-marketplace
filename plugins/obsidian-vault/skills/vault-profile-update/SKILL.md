---
name: vault-profile-update
description: Create or refresh a customer's fact sheet (00-Steckbrief.md) in the Obsidian vault from verifiable sources only - local customer repositories read-only (app.json, BC build artifacts, apps and dependencies, Git remotes, plans folders), Azure DevOps projects, dated meeting notes, and explicit user statements - and check off answered open questions. Use when adding a new customer to the vault, when the user says "Steckbrief anlegen", "Steckbrief pflegen", or "Steckbrief aktualisieren", after BC upgrades or new apps, or when customer context reports stale or contradictory facts.
argument-hint: "<customer> [repository folder] [new facts with source]"
user-invocable: true
---

# Update Customer Profile

Every table row needs a source; anything unknown stays `offen`. An interpretation is not a fact.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Establish the customer and the mode: new customer, refresh, or record supplied facts and answers. For a new customer, take the folder name from the user and create `00-Steckbrief.md` from `_templates/Steckbrief.md` plus the folders `Prozesse`, `Konzepte`, `Entscheidungen`, and `Meetings`. Done when the customer folder and mode are known.
2. Collect evidence without changing any source:
   - **Repositories:** run [Get-RepoFacts.ps1](scripts/Get-RepoFacts.ps1) with `-Path` set to the repository paths in the fact sheet or the customer folder under `C:\Dev\Customers` that the user names; separate several paths with `;`. It reads the local state of the remote default branch without fetching; say so in the source.
   - **Azure DevOps:** when tools are available, list the organization's projects and descriptions.
   - **Meetings** since the fact sheet's `stand`, cited as `Meeting YYYY-MM-DD`.
   - **User statements**, cited as `Angabe <Name>, YYYY-MM-DD`.
   - Done when every candidate value has a source or is `offen`.
3. Build a change list against the current fact sheet with the classes new, changed, reconfirmed, and not verifiable. Never remove a fact only because its source was unavailable; mark it `nicht geprüft`. Keep `aliases` complete with company names, DevOps project names, and repository names, and keep every repository link and local path in the repositories table, because customer resolution matches on them. Done when every row in the change list has a source.
4. Present the change list. Write a new fact sheet the user asked for directly; changes to an existing fact sheet pass the change gate. Done when the list is confirmed or declined.
5. Write through the write discipline. Set `stand` to the review date, and check off answered open questions with answer and source. Never copy SAS tokens, secrets, or download URLs from build settings. Done when the write discipline reports `passed`.

## Output

Return the fact-sheet link, the applied changes by class, and the remaining open questions.
