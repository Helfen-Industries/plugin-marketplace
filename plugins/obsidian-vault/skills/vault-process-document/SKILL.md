---
name: vault-process-document
description: Document a customer's current (Ist) or target (Soll) business process in the Prozesse folder of the Obsidian vault with trigger, roles and systems, a Mermaid swimlane flowchart, numbered steps, variants, documents and interfaces, and open questions. Use when the user wants to describe, map, visualize, or compare a business process such as order handling, picking, purchasing, production, or invoicing for a customer, or prepare process knowledge for a concept.
argument-hint: "<customer> <area> - <process> [ist | soll] [description or sources]"
user-invocable: true
---

# Document Process

A process note describes how the customer works independent of one requirement. The target process of a single requirement belongs in its concept's `Soll-Ablauf`.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Establish customer, area, process, and state `ist` or `soll`; the file name is `<Bereich> - <Prozess>.md`. When that note exists with another state, ask whether to update it or how to name the second note, because the contract has one name per process. Done when the target path and state are known.
2. Gather the user's description and related meetings, concepts, and processes through [Load Customer Context](../vault-customer-context/SKILL.md). Ask at most one question, and only when trigger, roles, or result are missing so that the flow cannot be drawn; record every other gap as an open question. Done when trigger, roles, steps, and result each have a source or an open question.
3. Fill `_templates/Prozess.md`:
   - **Ablauf:** Mermaid `flowchart LR` with one `subgraph` per role as swimlane and at most about 15 nodes; split larger processes into linked sub-processes.
   - **Schritte:** numbered as „Rolle: Tätigkeit → Ergebnis oder Beleg“, matching the diagram.
   - An `ist` note states observed behavior with sources only; a `soll` note marks every change against the current process.
   - Use business terms and Business Central page or document names, not object IDs.
   - Done when every section has content or an open question and diagram and steps describe the same flow.
4. Write through the write discipline and link related concepts and meetings. Use Draw.io only as `AGENTS.md` allows. Done when the write discipline reports `passed`.

## Output

Return the process link, state, number of steps, and open questions.
