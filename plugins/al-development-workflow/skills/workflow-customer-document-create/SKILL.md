---
name: workflow-customer-document-create
description: Create or update customer-facing documentation for an implemented Business Central feature from the canonical spec and verified final implementation. Use during pull-request preparation when customers need a non-technical explanation of what is new, how to set it up, how to use it, and any upgrade or limitation notes.
user-invocable: false
---

# Create Customer Feature Documentation

Write for Business Central users and administrators, not developers. Use the fixed [Customer Feature Template](assets/customer-feature-template.md). The canonical spec defines intended behavior; the final reviewed implementation and tests prove what was actually delivered.

## Input

Require a canonical spec, final reviewed diff, entry work item, authoritative requirement source, implemented scenario document, and `Ready for pull request` review result. Use the requirement-source ID and title for artifact identity. Preserve existing unrelated customer-authored content and ask before replacing a conflicting explanation.

## Process

1. Reconcile the spec, approved deviations, final implementation, and implemented test scenarios. Include only delivered behavior; do not document planned or unverified features. Done when each customer-facing statement maps to implemented behavior and test or review evidence.
2. Resolve the deterministic path `docs/features/{requirement-source-id-or-NOID}-{short-slug}.md`, unless the repository defines a stronger customer-documentation convention. Keep the assigned Task only as traceability metadata. Done when the target path and identity are explicit.
3. Populate every template section in the requirement's language. Explain business outcomes, user-visible behavior, setup, permissions, initial values, usage, upgrade or migration, limitations, and operational notes without AL object names, procedure names, source paths, code snippets, or internal architecture. Use `- None` when a section does not apply. Done when a customer can configure and use the delivered feature without reading the technical spec.
4. Cross-check setup and permissions against the final implementation and test scenarios. Do not invent UI paths, defaults, permission assignments, migration behavior, or limitations. Return unverifiable statements as documentation blockers. Done when all instructions are supported by the reviewed change.
5. Write or update only the customer document. Done when it is accurate, non-technical, complete, and ready to link from the pull request.

## Output

Return the customer-document path, delivered capabilities documented, setup and permission notes, upgrade impact, limitations, and any blocking gap. End with `Customer documentation ready` only when the artifact matches the final reviewed implementation.