---
name: workflow-code-explore
description: Explore the current workspace read-only to find the AL objects, symbols, tests, conventions, and controlling code paths relevant to a work package. Use after requirements analysis and before clarification or implementation planning.
user-invocable: false
---

# Explore Relevant Code

## Input

Require the analysis handoff, including its search targets and open decisions. Do not explore unrelated areas merely because they are nearby.

## Process

1. Start from concrete names, object IDs, tables, pages, codeunits, events, errors, or behaviors in the analysis handoff. Search narrowly for the code that directly controls each target behavior. Done when every target is tied to a controlling path or recorded as not found.
2. Inspect neighboring tests, call sites, extension points, and local conventions needed to explain the controlling path. Before using AL symbol tools for dependency objects, apply [AL Symbols MCP](../mcp-al-symbols/SKILL.md) to load and verify the owning project synchronously. Done when workspace evidence and dependency metadata are labeled separately.
3. Identify conflicts, remaining factual unknowns, and the narrowest validation available for the likely change. Do not modify files or run shell commands without explicit confirmation. Done when each unknown has a next evidence source and each affected behavior has a validation route.

## Handoff

Return:

- relevant files and AL objects
- controlling code path
- existing extension points and conventions
- nearby tests and validation commands
- conflicts between requirements and current behavior
- remaining unknowns

The handoff is complete when every analysis search target has evidence or an explicit retrieval gap, the controlling path is identified, and clarification can distinguish discoverable facts from user-owned decisions.