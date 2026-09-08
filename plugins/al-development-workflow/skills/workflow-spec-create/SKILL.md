---
name: workflow-spec-create
description: Create the canonical implementation-ready Business Central AL technical specification from clarified requirements and verified workspace evidence. Use only after critical decisions are resolved and relevant AL code has been explored.
user-invocable: false
---

# Create Implementation Plan

## Preconditions

Require completed analysis and exploration handoffs plus the confirmed decision ledger from clarification. Do not create a final plan while implementation-critical decisions remain open or shared understanding is unconfirmed. Return the open decisions or missing confirmation instead.

Read the [Technical Specification Contract](references/technical-spec-contract.md) and use the fixed [Technical Specification Template](assets/technical-spec-template.md).

Apply installed AL guidance for naming and namespaces, events, performance, error handling, translations, testing, and code style when those concerns appear. Use [AL Symbols MCP](../mcp-al-symbols/SKILL.md) for compiled object facts; do not restate generic AL rules inside the spec.

## Process

1. Resolve the entry work item and authoritative requirement source. Use the requirement-source ID, title, language, and short slug for `specs/{requirement-source-id-or-NOID}-{short-slug}.md`; retain the entry reference in metadata. Do not create the file before clarification and shared-understanding confirmation are complete. Done when both identities, their relation, and the deterministic path are explicit and the caller has authorized writing the artifact.
2. Populate every template section from requirement-source content, separately attributed entry-item constraints, verified workspace evidence, and confirmed decisions. Keep `- None` entries where required, preserve explicit exclusions, and list objects in dependency order. Done when no implementation-critical field depends on an unstated decision, unsupported guess, or unattributed source conflict.
3. Map every requirement and acceptance criterion to concrete design, at least one stable test scenario, and one ordered implementation step with a validation method. Do not assign IDs to new AL objects. Done when the mappings are complete and the object inventory agrees with the detailed sections.
4. Run the contract readiness gate and self-review. Reopen clarification for decisions and exploration for missing facts; do not conceal gaps with placeholders. Done when readiness is truthfully `Ready for implementation` or `Blocked` with exact gaps.
5. Write or update only the canonical spec file after write authorization. Preserve unrelated user changes when updating an existing spec. Done when the persisted document retains all fixed sections and can be consumed without reopening source material for basic implementation decisions.

Do not include effort, pricing, token usage, or fixed-price calculations. Those belong to `workflow-spec-estimate`.

The plan is complete when the canonical spec satisfies its readiness gate. Return the spec path and end only a ready spec with `Ready for implementation`; otherwise return the blocking gaps.