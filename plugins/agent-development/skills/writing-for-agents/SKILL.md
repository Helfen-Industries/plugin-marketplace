---
name: writing-for-agents
description: Write and revise documents consumed by agents. Use when creating or editing skills, agent instructions, prompts, workflow references, or other files whose wording must reliably change agent behavior.
---

# Writing for Agents

Write for predictable process, not identical prose. Every instruction must help the agent choose a branch, perform work, or know when work is complete.

When the document is a skill, read [Skill Mechanics](references/skill-mechanics.md).

## Context pointers

A context pointer names information outside the current context and states when to read it. Skill descriptions and links from an instruction file are context pointers.

- State what the target contains.
- Name each genuinely different trigger branch once.
- Put the strongest trigger language first.
- Inline a hard requirement when failing to follow the pointer would make the workflow incorrect.

## Information hierarchy

Keep operative steps and critical gates in the main document. Move detailed formats, examples, schemas, and domain variants into references that are loaded only when their branch applies. Bundle deterministic or repeatedly reconstructed work as scripts or templates.

## Steps and completion criteria

End every process step with a condition that is both checkable and demanding enough to prevent premature completion. Prefer `Done when every configured source has its required fields` over `Validate the setup`.

Split a workflow when a real context boundary, reusable discipline, or independently triggered behavior exists. Keep orchestrators thin: sequence dependencies and gates without copying their internal procedures.

## Leading language

Use compact terms the agent can reason with throughout execution, such as `frontier`, `read-only`, `single source of truth`, or `fail closed`. Define a new term only when it compresses repeated reasoning.

## Pruning

Test each sentence against default agent behavior. Delete instructions that do not change a decision or action. Remove duplicated rules, vague encouragement, decorative explanation, and examples that add no new branch. Resolve contradictions rather than adding another warning.

The document is complete when its trigger branches are discoverable, every operative step has a completion condition, dependencies are reachable, and no remaining sentence is a behavioral no-op.