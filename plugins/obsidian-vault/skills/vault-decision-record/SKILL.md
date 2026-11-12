---
name: vault-decision-record
description: Record, supersede, accept, or reject an architecture or business decision as an ADR in a customer's Entscheidungen folder of the Obsidian vault, with context, decision, rejected alternatives, consequences, and sources. Use when the user says "Entscheidung festhalten" or "ADR anlegen", records an agreed solution, when a meeting or concept produces a lasting decision, or when an existing decision is replaced or withdrawn.
argument-hint: "<customer> <decision> [source such as meeting or work item]"
user-invocable: true
---

# Record Decision

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Classify the operation as new, supersede, or status change, and resolve the customer. Done when both are known.
2. Search the customer's `Entscheidungen/` for ADRs on the same topic by title, decision text, and `devops`. When one exists, propose a supersede or status change instead of a duplicate. Done when no duplicate would be created.
3. Number a new ADR as the highest `ADR-NNNN` in the folder plus one, counting every status; never reuse a number. Done when the number is unused.
4. Fill the template `_templates/Entscheidung.md` from sources only:
   - **Kontext:** problem, forces, and constraints.
   - **Entscheidung:** one present-tense sentence starting with „Wir …“.
   - **Betrachtete Alternativen:** at least one rejected alternative with its reason. Ask once when none is known; if the user confirms there was none, record „Keine Alternative betrachtet (Angabe <Name>, YYYY-MM-DD)“.
   - **Konsequenzen:** positive, negative, and follow-up work.
   - **Quellen:** meeting link, `AB#<id>`, and who decided.
   - Set `status: akzeptiert` and `entscheider` only when a source names the decision as made and by whom; otherwise use `vorgeschlagen`.
   - Done when all sections are filled from sources and the status matches the evidence.
5. For a supersede, set `ersetzt` in the new ADR and `status: abgelöst` plus `ersetzt-durch` in the old one, each as a quoted wikilink such as `"[[ADR-0002 Titel]]"`. Changing the old ADR passes the change gate. Done when both ADRs reference each other.
6. When the decision came from a meeting or concept, link the ADR there under `## Entscheidungen` or in the `Top-Entscheidungen` table. Write every change through the write discipline. Done when it reports `passed` for every changed note.

## Output

Return the ADR link, number, and status, the replaced ADR if any, and the notes that now link to it.
