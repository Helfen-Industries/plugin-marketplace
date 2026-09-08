---
name: workflow-work-package-context-setup
description: Configure repository defaults for retrieving Azure DevOps work items and GitHub issues and for routing pull-request creation to Azure Repos or GitHub. Use when work-package or pull-request context is missing or incomplete.
user-invocable: false
---

# Setup Work Package Context

Create or update `.github/copilot/work-package-context.json` so work-package skills can resolve short Azure DevOps and GitHub references without guessing. Keep this repository-local configuration out of version control with a root `.gitignore` rule when Git ignore configuration is available.

Read [Work Package Context](references/work-package-context.md) before inspecting or writing configuration.

## Process

1. Inspect the current configuration, root `.gitignore`, Git remotes, default branch, and workspace metadata before asking questions. Recognize GitHub and Azure DevOps HTTPS or SSH remotes. Keep work-item source and pull-request provider separate. Determine whether the configuration path is already ignored or tracked. Done when every candidate value has an evidence source or is marked missing and the ignore state is known.
2. Infer only values supported by repository evidence. Distinguish observed values from proposed values; never infer credentials, tokens, or access rights. Done when conflicts and unsupported values are explicit.
3. Present the evidence-backed values and ask only for required values or default-source choices that remain missing or conflicting. Done when the proposed configuration has no unresolved required field.
4. Show the complete proposed configuration and the proposed root `.gitignore` change. Obtain explicit confirmation before writing either file. A correction, skipped answer, or request to proceed without confirmation is not consent. Done when the exact proposal is confirmed.
5. Create or update the configuration without replacing unknown properties or unrelated user changes. If the root `.gitignore` is writable, append `/.github/copilot/work-package-context.json` only when no existing rule already ignores that path; create `.gitignore` when absent. Preserve existing rules, comments, ordering, and line-ending style. Done when the configuration contains the confirmed values and the ignore rule is effective or its failure is reported.
6. Parse the written JSON and validate it against the shared contract. Verify that the configuration path is ignored; when this workflow added the root-anchored rule, re-read `.gitignore` and verify that exact entry occurs once. Done when the selected default source is complete, persisted values match the confirmed proposal, and ignore handling has been verified.

Do not write secrets. A rerun must update the existing files rather than create duplicate configuration or ignore entries. Adding an ignore rule does not untrack an already tracked configuration file; report that state and ask before running any command that removes it from the Git index.

The setup is complete only when the file parses, the selected default source is fully configured, persisted values match the confirmed proposal, ignore handling is verified or explicitly unavailable, and the user has been told which files and values were written. Otherwise end with `Blocked by setup` and name the unresolved requirement.