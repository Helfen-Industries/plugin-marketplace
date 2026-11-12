---
name: vault-concept-create
description: Create or revise a business concept (Konzept) for a customer requirement in the Obsidian vault, structured like Part A of the technical specification - summary and intention, initial situation and context, target process as a Mermaid flowchart with numbered steps, scope, and key decisions - with sourced facts, open questions, and linked ADRs. Use when the user wants to draft, write, structure, review, or tighten a concept or solution idea for a customer, prepare a work item before specification, or compare a concept with an existing technical spec.
argument-hint: "<customer> <work item ID or topic> [requirement text or sources]"
user-invocable: true
---

# Create Concept

A concept is the agreed business view of one requirement, readable by a consultant or customer without AL knowledge. Technical design stays in the repository's technical specification.

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Apply [Load Customer Context](../vault-customer-context/SKILL.md) with the customer and work item. When a concept with the same work item or topic exists, revise it instead of creating another. Done when the target is a new path or one existing concept.
2. Gather evidence and label each fact with its source:
   - the requirement from the user or the work item; read the work item with available Azure DevOps tools when only a reference is given, otherwise ask for its text;
   - the context brief, related meetings, and processes;
   - an existing technical spec under the repository's `plans/` folder, read-only.
   - Done when every Part A section has evidence or an explicit gap.
3. Draft the template sections:

   | Section | Rule |
   | --- | --- |
   | Zusammenfassung und Intention | 3–5 sentences: why the business needs it, benefit for whom, what the system does differently |
   | Ausgangslage und Kontext | at most 8 sentences or bullets: roles, affected process, verified current behavior, gap, prior work |
   | Soll-Ablauf | Mermaid `flowchart` with at most about 12 nodes including the unchanged standard path, followed by 5–8 numbered steps stating who does what and how the system responds |
   | Scope | `### Im Scope` and `### Nicht im Scope` as business capabilities |
   | Top-Entscheidungen | at most 7 confirmed decisions with reason and ADR link |

   Use business vocabulary and page or field captions; never name procedures, events, object IDs, internal field names, or files. Use Mermaid; use Draw.io only as `AGENTS.md` allows. Done when each section has content or a linked open question and the Mermaid block is valid `flowchart` syntax with unique node IDs.
4. Treat a decision as confirmed only when the user, a meeting note, or the work item states it. Unconfirmed decisions go under `## Offene Fragen`. Propose an ADR through [Record Decision](../vault-decision-record/SKILL.md) for each lasting confirmed decision without one. When open decisions block the target process, keep status `entwurf` and offer `workflow-decisions-grill` if that skill is available. Done when every key decision has a source and every ADR proposal is applied or declined.
5. Write through the write discipline with status `entwurf` unless the user confirms `abgestimmt`, `devops` set to the work item, and `spec` set to the absolute spec path when a spec exists. Done when the write discipline reports `passed`.
6. When a spec exists, compare its Part A (1. Summary, 2. Initial situation and context, 3. Target process, 4. Scope, 5. Key decisions) with the concept section by section and report the differences. Never edit the repository. Done when the differences are listed or `keine Abweichungen` is reported.

## Output

Return the concept link and status, its open questions, the ADR proposals with their state, and the spec differences.
