---
name: workflow-work-package-analyze
description: Analyze a normalized Business Central AL work package, separate verified requirements from assumptions, and identify acceptance criteria, dependencies, risks, and open implementation decisions. Use during work-package intake before code exploration or planning.
user-invocable: false
---

# Analyze Work Package

## Input

Require a [Normalized Work Package](../workflow-work-package-begin/references/normalized-work-package.md). If required source fields are missing, record the retrieval gap instead of filling it with an assumption.

## Process

1. Establish identity and provenance before interpreting content.
	- Preserve the assigned entry work item as the workflow and traceability reference.
	- Use the requirement source title, description, and acceptance criteria as the business requirement. For an Azure DevOps Task, this is its verified direct parent User Story.
	- Keep entry-Task instructions as implementation constraints or context, never as a replacement for parent requirements.
	- Done when every analyzed statement is attributable to the entry item, requirement source, comment, attachment, or direct input.
2. Classify each source statement as a verified requirement, acceptance criterion, implementation constraint, or unresolved decision. Preserve exact values, negative requirements, and contradictions between the entry item and requirement source. Done when every implementation-relevant source statement has one classification.
3. Identify affected Business Central areas, users, data, processes, integrations, permissions, translations, and non-functional concerns. Done when each relevant concern is either captured or explicitly marked not evidenced by the source.
4. Derive risks, dependencies, and concrete workspace search targets without turning inferred context into requirements. Done when each inference is labeled and every open decision states why implementation depends on it.

## Handoff

Return these sections:

- Entry work item and requirement source
- Objective
- Verified requirements
- Acceptance criteria
- Entry-item implementation constraints
- Constraints and dependencies
- Risks
- Open decisions
- Search targets for workspace exploration

The handoff is complete when the requirement source owns the objective and acceptance criteria, the entry item remains traceable, every acceptance criterion maps to a verified requirement or named contradiction, all assumptions remain visibly separate from source facts, and exploration can begin without reopening either item for basic context.