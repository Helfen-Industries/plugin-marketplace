---
name: workflow-pull-request-create
description: Prepare documentation and create a pull request for a reviewed Business Central AL implementation. Synchronize implemented test scenarios, create non-technical customer documentation, build the PR description, and route the confirmed write to GitHub or Azure Repos from repository context. Use only after workflow-code-review ends Ready for pull request.
argument-hint: <canonical spec path and reviewed implementation>
user-invocable: true
disable-model-invocation: true
---

# Create Pull Request

Prepare one reviewed change for provider-specific pull-request creation. Read the fixed [Pull Request Template](assets/pull-request-template.md).

## Preconditions

Require:

- canonical spec and final implementation
- `Ready for pull request` result from [Review AL Implementation](../workflow-code-review/SKILL.md)
- clean required tests, build, analyzers, and diagnostics
- entry work item and authoritative requirement source
- repository context with explicit `pullRequest.provider`

Do not create a PR from a blocked review, default branch, detached HEAD, empty branch diff, unresolved merge conflict, or unverified provider. The invocation authorizes local documentation preparation, not commit, push, or external PR creation without the confirmations below.

## Process

1. Read and validate `.github/copilot/work-package-context.json` using [Work Package Context](../workflow-work-package-context-setup/references/work-package-context.md). If pull-request provider or matching repository identity is missing, apply [Setup Work Package Context](../workflow-work-package-context-setup/SKILL.md). Treat work-item source and repository provider independently. Done when provider is explicitly `github` or `azure-devops` and its repository identity is complete.
2. Reconcile the spec, review result, final diff, commits, current branch, remote branch, target branch, entry Task, and requirement source. Exclude unrelated working-tree changes. Done when the PR scope is non-empty, reviewed, and maps entirely to the canonical spec and required documentation.
3. Apply [Document AL Test Scenarios](../al-test-document-scenarios/SKILL.md) to synchronize the documentation of implemented tests with actual scenario IDs, titles, Given/When/Then steps, and automation mappings. Done when every implemented scenario is documented and no stale or planned-only test is presented as implemented.
4. Apply [Create Customer Feature Documentation](../workflow-customer-document-create/SKILL.md). Done when the Story-based customer document accurately explains delivered behavior, setup, permissions, usage, upgrade impact, and limitations without technical implementation detail.
5. Review the documentation-only diff against the canonical spec, final reviewed implementation, implemented tests, and customer-document template. Verify that no production or test behavior changed after the code-review gate, every setup and permission statement is evidenced, scenario mappings remain synchronized, and all local links resolve. If documentation exposes an implementation discrepancy or requires code changes, return to `workflow-code-review`; do not carry the previous readiness result forward. Done when the generated documentation is accurate, complete, internally consistent, and the post-review diff contains documentation only.
6. Populate the PR template from the requirement source, assigned Task, reviewed implementation, customer document, synchronized test scenarios, validation evidence, and approved deviations. Keep reviewer-facing implementation notes concise and keep customer prose in the customer document. Done when title, body, links, draft state, source branch, target branch, and provider payload are complete.
7. Inspect repository state after documentation changes.
   - If required changes are uncommitted, show the exact scoped files and proposed commit message; obtain explicit confirmation before staging or committing.
   - If commits are not on the remote, show the exact remote and branch; obtain explicit confirmation before pushing.
   - Do not include unrelated files in a commit or push.
   - Done when the remote source branch contains the exact reviewed code and documentation to propose.
8. Present the immutable PR request: provider, repository, source and target branches, title, complete body, draft state, requirement source, entry Task, customer-document path, and test-scenario path. Obtain explicit confirmation to create that exact external PR. A prior confirmation to write, commit, or push is not PR-creation consent. Done when the final request is explicitly confirmed.
9. Route exactly once:
   - For `github`, apply [Create GitHub Pull Request](../workflow-github-pull-request-create/SKILL.md).
   - For `azure-devops`, apply [Create Azure Repos Pull Request](../workflow-azure-devops-pull-request-create/SKILL.md).
   - Never choose from the work-item provider or silently fall back to another provider.
   - Done when the selected adapter returns a PR URL and identifier or a concrete provider blocker.

## Output

Return provider, PR identifier and URL, source and target branches, draft state, requirement source, assigned Task, customer-document path, test-scenario document path, validation summary, and any provider warning.

End with `Pull request created` only after the provider confirms creation. Otherwise end `Blocked by pull request preparation` without claiming external success.