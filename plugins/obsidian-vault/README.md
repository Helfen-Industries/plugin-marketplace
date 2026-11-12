# Obsidian Vault

Agent workflows for a personal Obsidian knowledge vault with one folder per customer project: fact sheets, decisions (ADRs), concepts, processes, and meeting notes that GitHub Copilot can read and maintain.

## Get Started

Register the marketplace and install the plugin:

```powershell
copilot plugin marketplace add Helfen-Industries/plugin-marketplace
copilot plugin install obsidian-vault@helfen-agent-marketplace
copilot plugin list
```

Prerequisites:

- A vault at `C:\Dev\Knowledge`, or a path you name per request, containing `AGENTS.md` and `Kunden/`. The vault's `AGENTS.md` defines its structure.
- Windows PowerShell 5.1 or PowerShell 7 and Git for the bundled scripts.
- Optional: Azure DevOps tools (`ado-remote-mcp`) to read work items and projects.

Load the context of the customer whose repository is open:

```text
/obsidian-vault:vault-customer-context 15347
```

## Concept

### Two layers

| Layer | Holds | Location | Source of truth for |
| --- | --- | --- | --- |
| Knowledge | Fact sheet, decisions, concepts, processes, meetings | Vault `Kunden/<Kunde>/` | What the customer is, wants, and agreed |
| Delivery | AL code, technical specification, tests | Customer repository, `plans/` | How it is built |

The vault links to repository artifacts and never copies them. A concept stores the absolute spec path in `spec`.

### Vault contract

The vault's `AGENTS.md` is the single source of truth for folders, filenames, frontmatter, todo syntax, diagram formats, and links. Skills read it at run time and contain only procedures and gates, so convention changes happen in one place. `Test-VaultNote.ps1` is the executable check of that contract; when both disagree, `AGENTS.md` wins and the script is updated.

### Customer resolution

`Get-VaultCustomerContext.ps1` maps a request to exactly one customer folder, in this order:

1. explicit name: folder name, `kunde`, or `aliases`, exact before partial;
2. repository path listed in the fact sheet, including subfolders and the customer's parent folder;
3. Git remote URL listed in the fact sheet (HTTPS with or without user, SSH);
4. DevOps project or repository name listed in `aliases`.

Ambiguous results are asked, unresolved notes go to `_inbox/`. The fact sheet's `aliases` and repositories table therefore drive resolution and are kept current by `vault-profile-update`.

### Safety and gates

- Customer repositories and everything outside the vault are read-only; `Get-RepoFacts.ps1` never fetches or checks out.
- New notes are created only on request. Changing facts in a fact sheet, changing a decided ADR, and moving, renaming, or deleting notes require confirmation of the visible change.
- Facts need a source; unknown values stay `offen`. Secrets, SAS tokens, and download links are never written.
- Vault writes are committed locally per workflow, staging only the changed files. Pushing to the backup remote needs explicit confirmation each time.

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
| `vault-customer-context` | Public, read-only | Resolve the customer and return a linked brief of facts, decisions in force, concepts, processes, and open items |
| `vault-meeting-note` | Public driver | Turn raw notes or transcripts into a meeting note with decisions, questions, and todos, then propose follow-ups |
| `vault-concept-create` | Public driver | Create or revise a concept in Part A structure with a Mermaid target process |
| `vault-decision-record` | Public driver | Create, supersede, accept, or reject ADRs |
| `vault-profile-update` | Public driver | Create or refresh a fact sheet from repositories, DevOps, meetings, and statements |
| `vault-process-document` | Public driver | Document Ist or Soll processes with Mermaid swimlanes |
| `vault-maintenance` | Public driver | Check the vault against its contract and triage `_inbox/` |
| `vault-note-write` | Hidden primitive | Shared write discipline used by every writing workflow |

| Script | Purpose |
| --- | --- |
| `vault-customer-context/scripts/Get-VaultCustomerContext.ps1` | Customer resolution and context manifest as JSON |
| `vault-note-write/scripts/Test-VaultNote.ps1` | Contract check for frontmatter, filenames, ADR numbers, checkboxes, template remnants, and links |
| `vault-profile-update/scripts/Get-RepoFacts.ps1` | Read-only scan of app.json, build artifacts, remotes, and plans folders |

## Usage

```text
/obsidian-vault:vault-meeting-note Spacemann, heute, Abstimmung Kommissionierung: <Notizen>
/obsidian-vault:vault-concept-create Spacemann 15347 Produktionskommissionierung mit Tourdatum
/obsidian-vault:vault-decision-record Assmann: Wir nutzen die COSMO-Seriennummernlogik (Meeting 2026-11-10)
/obsidian-vault:vault-profile-update Assmann aus den Repos aktualisieren
/obsidian-vault:vault-process-document dtH Tiemann Verkauf - Auftragsabwicklung ist
/obsidian-vault:vault-maintenance Inbox aufräumen
```

Every workflow answers in the user's language and ends with the written note links, the vault check result, the local commit, and the push state.

See [CHANGELOG.md](CHANGELOG.md) for release history.
