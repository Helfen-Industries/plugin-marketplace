---
name: workflow-azure-devops-pull-request-create
description: Create one Azure Repos pull request from a fully prepared and explicitly confirmed request. Use only as the Azure DevOps provider adapter for workflow-pull-request-create after documentation, branch, push, title, description, target, and draft state are settled.
user-invocable: false
---

# Create Azure Repos Pull Request

Perform one provider write through `ado-remote-mcp`; do not prepare content or change repository files.

## Input contract

Require:

- `creationConfirmed: true`
- Azure DevOps organization, project, and repository
- remote source and target refs in `refs/heads/<branch>` form
- title under 72 characters
- complete description
- draft state
- requirement-source and entry-work-item IDs

Reject missing or placeholder values. Source and target refs must differ.

## Process

1. Resolve the Azure DevOps repository pull-request write tool from `ado-remote-mcp`. If unavailable, unauthenticated, or unauthorized, report the concrete blocker; do not substitute GitHub or a shell REST call. Done when the provider write tool is available.
2. Reconfirm that `creationConfirmed` applies to the exact organization, project, repository, refs, title, description, draft state, and work-item links received. Do not reinterpret or regenerate them. Done when the approved payload is immutable.
3. Call the Azure DevOps pull-request write operation with action `create`. Link the supplied requirement source and entry Task when supported. Create exactly one PR; do not vote, autocomplete, bypass policies, add reviewers, or update work-item state unless separately requested and confirmed. Done when Azure DevOps returns the PR ID, URL, source ref, and target ref.

Return the PR ID, URL, draft state, refs, and linked work-item IDs. On ambiguity or provider failure, create nothing and return `Blocked by Azure Repos pull request creation`.