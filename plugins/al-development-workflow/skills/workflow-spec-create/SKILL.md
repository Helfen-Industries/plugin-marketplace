---
name: workflow-spec-create
description: Create the canonical implementation-ready Business Central AL technical specification from clarified requirements and verified workspace evidence, structured as a reviewer-readable concept, an object-centric technical design with a complete Object catalog, and an evidence appendix. Use only after critical decisions are resolved and relevant AL code has been explored, including when a change request updates an existing spec or needs a delta spec for an implemented one.
user-invocable: false
---

# Create Implementation Plan

## Preconditions

Require completed analysis and exploration handoffs plus the confirmed decision ledger from clarification. Do not create a final plan while implementation-critical decisions remain open or shared understanding is unconfirmed. Return the open decisions or missing confirmation instead.

Read the [Technical Specification Contract](references/technical-spec-contract.md) and use the fixed [Technical Specification Template](assets/technical-spec-template.md). Read [Object Details](references/object-details.md) before writing Part B.

Apply installed AL guidance for naming and namespaces, events, performance, error handling, translations, testing, and code style when those concerns appear. Use [AL Symbols MCP](../mcp-al-symbols/SKILL.md) for compiled object facts; do not restate generic AL rules inside the spec.

## Process

1. Resolve the entry work item, the authoritative requirement source, and the target artifact. Search `plans/` for a spec covering the same requirement source or the behavior being changed, and apply the contract's change-request rule: new spec, in-place update of an unimplemented spec, or delta spec with its base. Never append a change to an implemented spec or to another requirement source's spec. Derive `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md` from the requirement-source ID and a short slug; retain the entry reference in metadata. Do not create the folder or file before clarification and shared-understanding confirmation are complete. Done when both identities, their relation, the route, and the deterministic path are explicit and the caller has authorized creating or updating exactly that artifact.
2. Write Part A from the requirement source and confirmed decisions in business language: Summary, Initial situation and context, Target process with a Mermaid flowchart and 5-8 steps, Scope, and at most seven key decisions. For a delta spec, describe the delivered state of the base as the initial situation. Done when a consultant without AL knowledge can review intention, process, and scope on about two pages and Part A names no procedures, events, files, internal field names, or object IDs.
3. Write Part B design from verified workspace evidence and confirmed decisions: Solution design, then the Object catalog with one row per AL object the work creates or modifies, then one Object details block per row in catalog order. Catalog changed existing objects as `Changed`, including enum and report extensions, signature changes, and modified subscriber codeunits. Do not assign IDs to new objects, fields, or enum values. Done when every new or changed member belongs to exactly one details block.
4. Evaluate every cross-cutting concern in the contract's fixed list. Write a subsection only for affected concerns not already complete in an object details block, and record every concern in C3 as covered or not affected with its reason. Done when every listed concern is either covered or justified as not affected.
5. Write Test scenarios, the Ordered implementation plan, and the appendix. Give every acceptance criterion at least one stable scenario, name catalog refs in every plan step, fill the C1 traceability matrix, and record every confirmed decision in C2. Done when the contract's completeness gate passes and C1 maps every acceptance criterion to objects, scenarios, and steps.
6. Run the contract readiness gate and the C3 self-review. Reopen clarification for decisions and exploration for missing facts; do not conceal gaps with placeholders or omitted catalog rows. Done when readiness is truthfully `Ready for implementation` or `Blocked` with exact gaps.
7. After write authorization, create the repository-root `plans` directory and the plan folder when absent, then write or update only the target `technical-spec.md`. For an in-place update, preserve unrelated user changes, increment `Version`, and add a C4 row; never modify the base spec of a delta. Do not create separate `specs` or `estimates` directories. Done when the persisted document follows the template's section order and can be consumed without reopening source material for basic implementation decisions.

Do not include effort, pricing, token usage, or fixed-price calculations. Those belong to `workflow-spec-estimate`.

The plan is complete when the canonical spec satisfies its readiness gate. Return the spec path, the route taken, and, for a delta spec, its base specification. End only a ready spec with `Ready for implementation`; otherwise return the blocking gaps.
