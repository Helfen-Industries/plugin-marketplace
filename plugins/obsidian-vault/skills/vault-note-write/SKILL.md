---
name: vault-note-write
description: Write, update, move, or delete notes in the personal Obsidian knowledge vault (default C:\Dev\Knowledge) under the vault's AGENTS.md contract - locate the vault, resolve the customer or project folder, search before creating, fill templates and frontmatter, gate changes to existing facts, verify with the vault check, and commit only versioned scaffold files. Use from every vault workflow before any file change, and whenever an agent is about to create or change a Markdown note in the vault.
user-invocable: false
---

# Write Vault Note

Shared write discipline for every `obsidian-vault` workflow. The caller owns the content; this skill owns where and how it is written.

## Boundaries

- **Vault root:** the path the user names, otherwise `C:\Dev\Knowledge`. It is valid only when it contains `AGENTS.md` and `10-Kunden/`; otherwise stop with `Blocked by vault`.
- **Contract:** the vault's `AGENTS.md` is the single source of truth for folders, filenames, frontmatter, task fields, todo syntax, diagrams, and links. Read it once per session before the first change and follow it; do not restate or override it. A request that needs a new top-level folder, a new frontmatter field, or a different filename pattern requires the user's decision before writing.
- **Scope:** change only Markdown notes under `00-Inbox/`, `10-Kunden/`, `20-Projekte/`, `30-Agents/`, and `80-Daily/`, plus the `.gitkeep` files of folders a workflow creates. Never change `.obsidian/`, `.git/`, `.gitignore`, `90-Templates/`, `99-System/` (including the generated calendar), `AGENTS.md`, `Dashboard.md`, or `Task Board.base` unless the user explicitly asks for that file. Everything outside the vault, including customer repositories, is read-only.
- **No secrets:** never write credentials, tokens, SAS signatures, or download links.

## Process

1. Verify the vault root and read `AGENTS.md`. Done when both exist and the contract has been read in this session.
2. Select the target place `<Ort>`: `10-Kunden/<Kunde>` or `20-Projekte/<Projekt>`. Use the place the caller already resolved; otherwise run [Get-VaultCustomerContext.ps1](../vault-customer-context/scripts/Get-VaultCustomerContext.ps1) with `-ResolveOnly` and `-Customer` (customer or project name) or `-Path`, and take `customer.ort` and `customer.bereich`. For `ambiguous`, ask the user to choose one of the `candidates`. For `unresolved`, write to `00-Inbox/` and add „Kunde oder Projekt zuordnen“ under `## Offene Fragen`. Notes without customer or project reference that `AGENTS.md` places under `30-Agents/` or `80-Daily/` go there. Done when exactly one folder is selected.
3. Search before creating: look in the target folder for a note with the same work-item ID in `devops`, the same date and topic, or the same decision topic; for mail content search the whole vault for the same `mail-id`. Prefer extending that note. Done when the target is either an existing note or a new path that does not collide.
4. Compose new notes from the template that `AGENTS.md` assigns to the type. Replace `{{title}}`, `{{date:…}}`, and `{{time:…}}`, remove every `<!-- … -->` hint, keep headings and their order, and drop checkbox lines without text. Fill `kunde` under `10-Kunden/` and `projekt` under `20-Projekte/` with the exact folder name and delete the other field; a note never carries both. Fill every mandatory field; a missing source value the user cannot supply is written as `offen`. Done when no placeholder or hint remains and every mandatory field has a value.
5. Apply the change gate:
   - Creating a note the user asked for, appending to a note, or checking off items within the request: allowed.
   - Changing or removing existing facts in `00-Steckbrief.md`, changing an ADR whose status is not `vorgeschlagen`, and moving, renaming, or deleting any note: show the exact before/after first and obtain explicit confirmation. Approval of the overall workflow does not confirm a change the user has not seen.
   - Done when every change is in the allowed class or explicitly confirmed.
6. Write UTF-8 with LF line endings, then run [Test-VaultNote.ps1](scripts/Test-VaultNote.ps1) with `-Path` set to the changed files (separate several with `;`). Fix every error and every `template`, `kunde`, `projekt`, `zuordnung`, `checkbox`, or `link` warning this change introduced. Done when the check reports `passed` for the changed files, or each remaining error is reported with its reason.
7. Version only scaffold. The vault's `.gitignore` excludes all notes in `00-Inbox/`, `10-Kunden/`, `20-Projekte/`, `30-Agents/`, `80-Daily/`, and `99-System/Kalender/`; they stay local and are never committed. Never use `git add -f`, never change `.gitignore`, and never commit to make up for ignored content. Run `git status --porcelain -- <changed paths>`; when it lists none of them, the commit state is `nicht versioniert`. Otherwise stage only the listed files this workflow changed with `git add -- <paths>` and commit locally with the message `<Typ>: <Kunde oder Projekt> – <Titel>` and the trailer `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`. Leave other working-tree changes untouched and name them. Ask whether to push only after a commit; push only after an explicit yes for this push. Done when the commit state is a commit hash, `nicht versioniert`, or a reported error, and the push state is `gepusht`, `nicht gepusht`, or a reported push error.

Run the scripts with Windows PowerShell from this plugin's skill directories, for example:

```powershell
powershell -NoProfile -File "<skills>\vault-note-write\scripts\Test-VaultNote.ps1" -Path "C:\Dev\Knowledge\10-Kunden\Assmann\Meetings\2026-11-12 Abstimmung.md"
```

## Output

Return the changed notes as links, the check result, the commit state, and the push state.
