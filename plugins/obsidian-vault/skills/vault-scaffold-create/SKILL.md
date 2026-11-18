---
name: vault-scaffold-create
description: Create the scaffold for a new customer, internal project, or Teilprojekt in the Obsidian knowledge vault - the folder with every subfolder from AGENTS.md and its .gitkeep files, the fact sheet or the Teilprojekt start page from the template, the name in the customer or project list of AGENTS.md, and on request the teilprojekt field on existing notes. Use when the user says "Kunde anlegen", "neues Projekt anlegen", "Teilprojekt anlegen", "Gerüst anlegen", wants to split a customer's work into Teilprojekte such as an interface, or needs the structure for a new customer or project before writing notes.
argument-hint: "<Kunde | Projekt | Teilprojekt> <name> [owner customer or project for a Teilprojekt] [aliases]"
user-invocable: true
---

# Create Vault Scaffold

Creates structure, not facts. Every value that is not a name or a date comes from the user or a source, or stays `offen`.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change. The script [New-VaultScaffold.ps1](scripts/New-VaultScaffold.ps1) performs the creation; it never overwrites, never touches `AGENTS.md`, and never commits.

## Process

1. Establish the type, the exact name, and for a Teilprojekt the owner. Types:
   - **Kunde:** folder under `10-Kunden/`.
   - **Projekt:** an own undertaking without customer assignment under `20-Projekte/`; work for a customer is never a project.
   - **Teilprojekt:** a delimited part of a customer or project undertaking with its own contacts or repository, stored under `<Ort>/Teilprojekte/`.
   - Ask once when the type is unclear, for example whether a customer's interface is a Teilprojekt (yes) or an own project (no, `AGENTS.md` keeps customer undertakings under the customer). Take names exactly as the user writes them; a Teilprojekt name must not contain a comma, and no name may contain `\ / : * ? " < > | # ^ [ ]`. Resolve the owner with [Load Customer Context](../vault-customer-context/SKILL.md) (`-ResolveOnly`, `-Customer`). Done when type, name, and owner are known.
2. Search before creating: run the resolver with `-Customer <name>`. A match by folder, alias, or Teilprojekt name means the entry exists; report it and offer [Update Customer Profile](../vault-profile-update/SKILL.md) instead of a second one. Done when the name is unused or the existing entry is reported.
3. Run the script with Windows PowerShell:

   ```powershell
   powershell -NoProfile -File "<skills>\vault-scaffold-create\scripts\New-VaultScaffold.ps1" -Type Teilprojekt -Name FLS -Owner Assmann -Aliases "FLS;Assmann FLS"
   ```

   Add `-DryRun` first when the user wants a preview. `-Aliases` takes the short name, the repository name, and the DevOps names, separated with `;`, because resolution matches on them. Statuses: `created` and `planned` succeed; `exists`, `invalid`, `ambiguous`, `owner-not-found`, and `template-missing` end the step with the reported reason. A new customer or project gets its folder, all subfolders with `.gitkeep`, and `00-Steckbrief.md`; a Teilprojekt gets `Teilprojekte/<Name>.md`, and the owner's fact sheet gets the section `## Teilprojekte` with the embedded overview when it lacks one. Done when the status is `created`.
4. For a customer or project, check `agentsMdListed` in the result. When `false`, propose adding the name to the `Kunden:` or `Projekte:` line of `AGENTS.md` and change that file only after confirmation. Done when the name is listed or the proposal is declined.
5. Fill what is known, nothing else:
   - **Teilprojekt:** purpose, delimitation, contacts, and repositories from the owner's fact sheet (source `Steckbrief <Ort>`) and from user statements (`Angabe <Name>, YYYY-MM-DD`); the repository row needs its link and its local path in backticks, because the resolver maps a repository path to the Teilprojekt through it. Open points become `- [ ]` under `## Offene Fragen`.
   - **Kunde or Projekt:** offer [Update Customer Profile](../vault-profile-update/SKILL.md) for repositories, DevOps projects, and contacts instead of copying values by hand.
   - Done when every table row has a source or `offen`.
6. For a Teilprojekt, offer to tag existing notes of the owner: list the notes whose title, `devops`, or content name the Teilprojekt, an alias, or its repository, and propose `teilprojekt: [<Name>]` for each; a topic that spans several Teilprojekte gets a list. Show each frontmatter change before and after and apply only confirmed ones; a decided ADR counts as a change that needs confirmation. Never guess a Teilprojekt for a note without evidence. Done when every proposal is applied or declined.
7. Run the vault check for every created or changed note, then version the scaffold per the write discipline: the new `.gitkeep` files and a confirmed `AGENTS.md` change are committed locally, notes stay `nicht versioniert`. Done when the check reports `passed` and the commit state is known.

## Output

Return the created folders and notes as links, the `AGENTS.md` state, the tagged notes, the open questions, the check result, the commit state, and the push state.
