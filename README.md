# Helfen Agent Marketplace

Private Agent Plugins 1.0 marketplace for GitHub Copilot in VS Code and GitHub Copilot CLI.

## Install

Authenticate Git for the private repository, then register the marketplace and install either plugin:

```powershell
copilot plugin marketplace add Helfen-Industries/plugin-marketplace
copilot plugin install al-development-workflow@helfen-agent-marketplace
copilot plugin install agent-development@helfen-agent-marketplace
```

List the installed plugin:

```powershell
copilot plugin list
```

## AL Development

See the [AL Development Workflow guide](plugins/al-development-workflow/README.md) for prerequisites, contents, generated artifacts, safety gates, and the complete delivery sequence.

Start a work package with either a source reference or a directly supplied requirement:

```text
/al-development-workflow:workflow-work-package-begin <reference or requirement with acceptance criteria>
/al-development-workflow:workflow-spec-estimate <path to canonical spec>
/al-development-workflow:workflow-spec-implement <path to canonical spec>
/al-development-workflow:al-test-document-scenarios <assigned Task or spec path, feature, and feature code>
/al-development-workflow:al-test-run-tdd <scenario ID, test method, feature suite, or test app>
/al-development-workflow:workflow-code-review <canonical spec path and implemented change>
/al-development-workflow:workflow-pull-request-create <canonical spec path and reviewed implementation>
/al-development-workflow:simplify-code <implemented AL change or files to simplify>
/al-development-workflow:simplify-codebase <repository, app, or subsystem scope>
/al-development-workflow:workflow-decisions-grill <subject and unresolved decisions>
```

Azure DevOps retrieval requires the separately installed and enabled `cosmo-bc-dev@agent-plugin-marketplace` plugin, which contributes the `ado-remote-mcp` server. The workflow resolves its Work Item Tracking tools on demand, so the remote server does not need to be connected before the workflow starts.

For an assigned Azure DevOps Task, the workflow keeps that Task as the entry and traceability reference, then retrieves its direct parent User Story as the authoritative source for title, description, acceptance criteria, specification identity, and test-scenario IDs. A missing or inaccessible parent blocks specification rather than promoting the Task description into a requirement. GitHub issues and direct input act as both entry and requirement source. All branches analyze requirements, explore relevant AL code, clarify unresolved decisions, and produce the same canonical technical spec after confirmation.

`workflow-spec-estimate` derives a comparable estimate and `workflow-spec-implement` implements the ready spec. `al-test-document-scenarios` maintains stable Given/When/Then specifications, while `al-test-run-tdd` proves the implemented behavior. Both test skills are user-invocable and may also be invoked by agents when a workflow detects missing scenario documentation, test drift, or required executable validation. `workflow-code-review` runs `simplify-code`, performs a findings-first whole-change review, repairs unambiguous defects, and produces the `Ready for pull request` gate. `workflow-pull-request-create` synchronizes implemented-test documentation, creates Story-based non-technical customer documentation under `docs/features`, reviews that documentation-only diff, prepares the PR description, and routes the confirmed PR to GitHub or Azure Repos from explicit repository context. `simplify-codebase` remains a read-only repository-wide audit. Supporting workflow and MCP primitives remain hidden from the slash-command menu.

AL code exploration uses the hidden `mcp-al-symbols` primitive to select the owning AL project, load package symbols before querying, and recover safely from an empty package index.

On first source-reference or pull-request use in a repository, it creates `.github/copilot/work-package-context.json` after confirmation. Direct requirements do not require this setup. The file stores non-secret work-item defaults and an independent pull-request provider: `azure-devops` for the legacy Azure Repos setup or `github` for the current GitHub repository setup. The same confirmed setup adds a root `.gitignore` rule so the repository-local context is not committed.

## Agent Development

See the [Agent Development guide](plugins/agent-development/README.md) for contents, examples, and the skill-authoring workflow.

The Agent Development plugin provides reusable disciplines and workflows for authoring agent-facing files:

```text
/agent-development:create-agent-skill
```

It includes skill creation and writing-for-agents guidance and is the home for future agent, prompt, instruction, and workflow-development skills.

## Validate

Run the repository checks before publishing:

```powershell
powershell -NoProfile -File ./scripts/validate-marketplace.ps1
```

The checks validate manifests, versions, source paths, skill metadata, internal links, eval coverage, and common secret patterns.

## Release

1. Update the changed plugin's version in its `plugin.json` and `.github/plugin/marketplace.json` entry.
2. Update the changed plugin's `CHANGELOG.md`.
3. Run the validator and complete a local Copilot CLI installation smoke test.
4. Create a matching Git tag and GitHub Release.

## Security

Review every plugin before installation because plugins can contain instructions, scripts, hooks, and MCP servers. Never commit credentials. See [SECURITY.md](SECURITY.md) for reporting and release requirements.