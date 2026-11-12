# Normalized Work Package

Every source retrieval skill returns the same handoff.

## Identity model

- **Entry work item**: the Task, issue, or direct input supplied by the user. Preserve its source type, canonical reference, ID, type, title, state, assignee, and relation to the requirement source. It remains the workflow entry point and traceability anchor.
- **Requirement source**: the item that owns the business purpose and acceptance criteria. For an Azure DevOps Task, this is its direct parent User Story. For a User Story, Bug, GitHub issue, or direct input that already owns the requirement, it is the entry item itself.

Do not use the entry Task ID as the feature, specification, or scenario identity when a parent User Story is the requirement source.

## Required fields

- source system
- entry work item identity and canonical reference
- requirement source identity and canonical reference
- relation from entry work item to requirement source
- requirement-source title, description, and acceptance criteria, preserving checklists and exact constraints
- implementation-relevant entry-item instructions or constraints, kept separate from parent requirements
- attachments and links, including inaccessible attachment URLs
- metadata for both identities such as state, labels, area, iteration, milestone, and assignee when available
- parent, child, and related work items or issues when relevant
- retrieval gaps or access limitations

Keep source facts distinct from interpretation. Parent requirements and Task-specific implementation notes must remain attributable to their source. Record contradictions instead of silently preferring either item. Missing information remains missing; do not turn it into an empty requirement or an inferred decision.

The handoff is complete when downstream analysis can identify the entry reference, authoritative requirement identity, verified requirements, Task-specific constraints, unresolved decisions, and concrete workspace search targets without reopening either item for basic fields.

## Optional customer context

When available, attach the customer-context brief from the personal knowledge vault with its note links and fact-sheet date. Keep it in its own section labeled as vault context. It informs constraints, decisions in force, and open questions, but it is never a requirement source and never fills a missing requirement field.
