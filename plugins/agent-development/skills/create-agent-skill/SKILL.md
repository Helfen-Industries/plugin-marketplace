---
name: create-agent-skill
description: Create or substantially revise an agent skill from an intended behavior, including discovery metadata, workflow structure, references, eval cases, documentation, and validation. Use when adding a skill or turning a repeated agent workflow into a reusable skill.
---

# Create Agent Skill

Apply [Writing for Agents](../writing-for-agents/SKILL.md) and read its [Skill Mechanics](../writing-for-agents/references/skill-mechanics.md).

## Process

1. Capture intent: what behavior the skill enables, which prompts should trigger it, its observable output, side effects, confirmation gates, and required tools. Done when each item is known or explicitly out of scope.
2. Inspect neighboring skills, plugin conventions, validation scripts, and existing eval formats. Done when the new skill has a chosen plugin, role, name, and nearest local pattern.
3. Design the smallest skill architecture. Separate drivers, reusable primitives, references, scripts, and assets only where they have distinct responsibilities. Done when every file has one reason to exist.
4. Draft the skill with rich discovery metadata, explicit dependencies, operative steps, and checkable completion criteria. Done when every trigger branch has a path through the workflow and every side effect has a confirmation boundary.
5. Add realistic eval cases for a normal request, a missing or ambiguous precondition, and pressure to bypass a gate. Done when expected outputs describe observable behavior and would fail for a naive default response.
6. Update the plugin changelog and user-facing documentation. Run the repository validator and the narrowest available evals. Done when validation passes and no stale references remain.

Do not create abstractions merely to make the skill tree look systematic. Reuse is evidence for extraction; visual symmetry is not.