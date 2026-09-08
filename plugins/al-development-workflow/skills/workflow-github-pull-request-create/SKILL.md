---
name: workflow-github-pull-request-create
description: Create one GitHub pull request from a fully prepared and explicitly confirmed request. Use only as the GitHub provider adapter for workflow-pull-request-create after documentation, branch, push, title, body, base, and draft state are settled.
user-invocable: false
---

# Create GitHub Pull Request

Perform one provider write; do not prepare content or change repository files.

## Input contract

Require:

- `creationConfirmed: true`
- owner and repository
- remote source branch and target branch
- title under 72 characters
- complete PR body
- draft state
- requirement-source and entry-work-item references

Reject missing or placeholder values. The source branch must exist on the GitHub remote and differ from the target branch.

## Process

1. Resolve the GitHub Pull Requests extension's pull-request creation capability. If unavailable or unauthenticated, report the concrete dependency or authentication blocker; do not substitute Azure DevOps or a shell API call. Done when the provider tool is available.
2. Reconfirm that `creationConfirmed` applies to the exact owner, repository, branches, title, body, and draft state received. Do not reinterpret or regenerate them. Done when the approved payload is immutable.
3. Create exactly one pull request. Do not merge it, enable auto-merge, request reviewers, add labels, or edit linked work items unless separately requested and confirmed. Done when GitHub returns the pull-request number, URL, source branch, and target branch.

Return the pull-request number, URL, draft state, and branches. On ambiguity or provider failure, create nothing and return `Blocked by GitHub pull request creation`.