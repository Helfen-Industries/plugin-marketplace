---
name: workflow-github-issue-get
description: Retrieve a GitHub issue and its implementation-relevant context using read-only tools. Use for GitHub issue URLs, owner/repository#number references, or requests to begin work from a GitHub issue.
user-invocable: false
---

# Get GitHub Issue

## Input

Require a GitHub issue URL or an `owner/repository#number` reference. A bare issue number is valid only when the active repository is unambiguous.

Read [Work Package Context](../workflow-work-package-context-setup/references/work-package-context.md) for repository defaults and resolution precedence.

## Procedure

1. Resolve owner, repository, and issue number from explicit input, then valid repository defaults. Done when the canonical reference is unambiguous or the exact missing value has been requested.
2. Use GitHub read tools to retrieve the issue body, state, labels, assignees, milestone, comments, and linked issues or pull requests when relevant. Done when the source facts needed by the normalized handoff are present or recorded as retrieval gaps.
3. Preserve task lists, acceptance criteria, and exact constraints. Record inaccessible attachments as links without inventing their content. Return [Normalized Work Package](../workflow-work-package-begin/references/normalized-work-package.md). Done when its completion condition is satisfied or every unavailable field is named.

## Failure handling

- If GitHub issue tools are unavailable, state the missing capability and ask the user to provide the issue content.
- If the repository or issue is inaccessible, report that result without trying alternate credentials.
- Never edit the issue, add comments, labels, or assignees, and never change its state.

End an unresolved or failed retrieval with `Blocked by retrieval` and the minimum information needed to resume.