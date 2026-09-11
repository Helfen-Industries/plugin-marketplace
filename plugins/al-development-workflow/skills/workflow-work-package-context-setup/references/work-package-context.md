# Work Package Context

Repository-specific source defaults live in `.github/copilot/work-package-context.json`.

This is repository-local configuration. When Git ignore configuration is available, the setup workflow ensures the repository root `.gitignore` ignores both the context file and generated planning artifacts with the root-anchored rules `/.github/copilot/work-package-context.json` and `/plans/`. It preserves existing content and does not add a redundant rule when either path is already ignored.

## Format

```json
{
  "version": 1,
  "defaultSource": "azure-devops",
  "branch": {
    "prefix": "JHE"
  },
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

`branch.prefix` is required before implementation. It stores the developer or team abbreviation used for implementation branches and must match `^[A-Za-z0-9][A-Za-z0-9._-]*$`. The implementation branch name is `{prefix}/{entry-reference-number-or-NOID}-{plan-slug}`. Build `plan-slug` from one to three meaningful words in the ordered implementation plan, convert it to lowercase kebab-case, transliterate non-ASCII letters, and remove punctuation and filler words. Use the entry work item or issue number, not a parent requirement-source number; use `NOID` only when the direct requirement has no reference.

`pullRequest` is optional until pull-request preparation. Its `provider` is `azure-devops` or `github`; `targetBranch` is optional and otherwise comes from the verified remote default branch. For Azure Repos, `azureDevOps.repository` is required. For GitHub, the `github` object must be complete. The work-item source and pull-request provider are independent: a repository may use Azure DevOps work items with either Azure Repos or GitHub.

## Resolution rules

1. An explicit full URL or `owner/repository#number` reference wins over repository defaults.
2. Use repository defaults to complete a short reference, such as a bare work item or issue number.
3. Use `defaultSource` only when the reference itself does not identify Azure DevOps or GitHub.
4. Report a conflict between explicit input and configuration, but follow the explicit input for the current request. Do not rewrite configuration implicitly.
5. Never read credentials, tokens, or authentication material from this file.
6. Use `pullRequest.provider` for PR routing. Do not infer the provider merely because the work item came from Azure DevOps.
7. Use `branch.prefix` only for local implementation branch naming. Do not infer it from Git identity, repository ownership, or work-item assignment.

## Validation

The configuration is valid for work-package retrieval when it is a JSON object with `version` equal to `1`, `defaultSource` equal to `azure-devops` or `github`, and a complete object for the selected source. It is valid for implementation when `branch.prefix` is present and matches the required pattern. It is valid for pull-request creation when `pullRequest.provider` is supported and its matching repository identity is complete. Ignore unknown properties so the format can evolve compatibly.

Ignore rules affect untracked files only. If the configuration or `plans` content is already tracked, report that adding `.gitignore` does not remove it from the Git index; removing tracked paths from the index is a separate side effect that requires explicit confirmation.

## Workspace visibility

When the repository contains a `.code-workspace` file, expose the repository-root `plans` directory in one selected workspace file. Prefer the currently opened repository workspace identified by editor metadata. If no active file is identifiable, select the only candidate; when multiple candidates remain, require the user to choose one before proposing changes.

Workspace folder paths resolve relative to the directory containing the `.code-workspace` file. Compute the `plans` path from that directory and use forward slashes; the root-level entry is `{ "name": "plans", "path": "plans" }`, while a workspace file in `.vscode` requires `{ "name": "plans", "path": "../plans" }`. Treat an existing folder entry as a match when its path resolves to the repository-root `plans` directory, regardless of its name or path spelling.

VS Code workspace files are JSON with Comments. Read and validate them as JSONC, and use a structured edit that preserves comments, trailing commas, unrelated folders and settings, formatting, and line endings. Include the selected file and exact folder entry in the confirmed proposal. If no repository `.code-workspace` file exists, report workspace visibility as unavailable and do not create one implicitly.