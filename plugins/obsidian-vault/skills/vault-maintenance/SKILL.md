---
name: vault-maintenance
description: Check and tidy the Obsidian knowledge vault - validate frontmatter, filenames, ADR numbering, checkbox placement, template remnants, and links against the vault's AGENTS.md, report stale fact sheets and forgotten open items, and triage notes in _inbox to customers. Use when the user asks to "Inbox aufräumen", "Vault prüfen", clean up, check, or tidy the knowledge base, or after many manual edits in Obsidian.
argument-hint: "[prüfen | aufräumen] [customer or folder]"
user-invocable: true
---

# Maintain Vault

Report only by default. Change notes only when the user asked to tidy up or confirms a proposed fix, and apply [Write Vault Note](../vault-note-write/SKILL.md) for every change.

## Process

1. Run [Test-VaultNote.ps1](../vault-note-write/scripts/Test-VaultNote.ps1) for the whole vault, or with `-Path` for the requested customer folder. Done when its JSON result is available.
2. Report the findings grouped by customer: errors, warnings, info (fact sheets older than 90 days, open items in notes older than 30 days), and every note in `_inbox/`. When `AGENTS.md` and the script disagree, `AGENTS.md` wins; report the drift. Done when every finding appears exactly once.
3. Propose a fix for each finding, split into mechanical fixes (frontmatter value, missing tag, filename date) and content decisions (customer assignment, move, merge, old open items). Never close a todo or question on your own; propose done, still open, or obsolete. Done when every finding has a proposal or `keine Aktion` with a reason.
4. Triage `_inbox/`: determine the customer through the resolver in [Load Customer Context](../vault-customer-context/SKILL.md) using names and aliases from the note, then the target type and filename. Propose moving, merging into an existing note, or deleting an empty note; each needs confirmation. Leave an unassignable note in `_inbox/` with „Welchem Kunden gehört diese Notiz?“ under `## Offene Fragen`. Done when `_inbox/` is empty or each remaining note holds that question.
5. Apply the confirmed fixes and rerun the check. Done when the check reports `passed` or each remaining finding is listed with its reason.

## Output

Return finding counts before and after, the applied changes, and the remaining findings.
