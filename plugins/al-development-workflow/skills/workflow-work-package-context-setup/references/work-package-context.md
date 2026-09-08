# Work Package Context

Repository-specific source defaults live in `.github/copilot/work-package-context.json`.

This is repository-local configuration. When Git ignore configuration is available and no existing rule ignores the path, the setup workflow adds the root-anchored rule `/.github/copilot/work-package-context.json` to the repository root `.gitignore`. It preserves existing content and does not add a redundant rule when the path is already ignored.

## Format

```json
{
  "version": 1,
  "defaultSource": "azure-devops",
  "pullRequest": {
    "provider": "github",
    "targetBranch": "main"
  },
  "azureDevOps": {
    "organization": "example-organization",
    "project": "Business Central",
    "repository": "example-extension"
  },
  "github": {
    "owner": "example-owner",
    "repository": "example-extension"
  }
}
```

`azureDevOps` and `github` are optional, but the object selected by `defaultSource` must exist and be complete. Azure DevOps requires `organization` and `project`; GitHub requires `owner` and `repository`.

`pullRequest` is optional until pull-request preparation. Its `provider` is `azure-devops` or `github`; `targetBranch` is optional and otherwise comes from the verified remote default branch. For Azure Repos, `azureDevOps.repository` is required. For GitHub, the `github` object must be complete. The work-item source and pull-request provider are independent: a repository may use Azure DevOps work items with either Azure Repos or GitHub.

## Resolution rules

1. An explicit full URL or `owner/repository#number` reference wins over repository defaults.
2. Use repository defaults to complete a short reference, such as a bare work item or issue number.
3. Use `defaultSource` only when the reference itself does not identify Azure DevOps or GitHub.
4. Report a conflict between explicit input and configuration, but follow the explicit input for the current request. Do not rewrite configuration implicitly.
5. Never read credentials, tokens, or authentication material from this file.
6. Use `pullRequest.provider` for PR routing. Do not infer the provider merely because the work item came from Azure DevOps.

## Validation

The configuration is valid for work-package retrieval when it is a JSON object with `version` equal to `1`, `defaultSource` equal to `azure-devops` or `github`, and a complete object for the selected source. It is valid for pull-request creation when `pullRequest.provider` is supported and its matching repository identity is complete. Ignore unknown properties so the format can evolve compatibly.

The ignore rule affects untracked files only. If the configuration is already tracked, report that adding `.gitignore` does not remove it from the Git index; removing it from the index is a separate side effect that requires explicit confirmation.