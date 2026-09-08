---
name: simplify-codebase
description: Audit an AL repository or selected subsystem for readability, maintainability, unnecessary complexity, duplication, and AI slop. Use for repository-wide simplification reviews, technical-debt discovery, or selecting cleanup work before implementation.
argument-hint: <repository, app, or subsystem scope>
user-invocable: true
---

# Codebase Simplify Audit

Perform a read-only repository audit. Identify and prioritize simplification opportunities; do not edit files. Use [Code Simplify](../simplify-code/SKILL.md) later to implement an accepted finding and its shared [Simplification Lens](../simplify-code/references/simplification-lens.md) for evaluation criteria.

## Process

1. Establish scope and exclusions. Default to the active repository, but separate AL apps, test projects, generated output, vendored code, dependencies, migrations, and archived code before scanning. Done when every included area has a reason to inspect and every excluded area is named.
2. Map the repository structure, ownership boundaries, build and test entry points, and representative local conventions. Use workspace search for source and apply [AL Symbols MCP](../mcp-al-symbols/SKILL.md) only when compiled symbols or cross-object references are needed. Done when findings can be judged against actual repository patterns rather than generic preferences.
3. Scan the included scope using the shared simplification lens. Search for repeated structures and suspicious patterns, then read complete definitions, usages, call sites, and nearby tests before treating a match as a finding. Done when each candidate is verified, rejected, or marked uncertain with the missing evidence named.
4. Group findings by root cause and ownership boundary. Rank each group by maintenance impact, confidence, implementation effort, behavior risk, and breadth. Do not inflate the report with repeated instances or low-value style preferences. Done when every reported finding has evidence, a concrete simplification direction, and a safe validation route.
5. Produce the audit report without changing the repository. Recommend bounded follow-up batches that can be implemented and validated independently with [Code Simplify](../simplify-code/SKILL.md). Done when the user can select a batch without repeating repository discovery.

## Output

Lead with findings ordered by impact. For each finding include:

- affected files, objects, or subsystem
- evidence and repeated instances
- complexity or AI slop being carried
- proposed simplification and preserved behavior
- confidence, effort, behavior risk, and validation route

Then list:

- scope inspected and exclusions
- candidates rejected after verification
- uncertain candidates and missing evidence
- recommended implementation batches
- overall validation or analysis limitations

If no actionable opportunities are found, say so and report the inspected scope and residual blind spots. The audit is complete when the declared scope has been sampled systematically, every finding is evidence-backed and deduplicated, and no files or external systems were changed.
