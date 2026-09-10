# AL Development Workflow

Structured Business Central AL delivery from requirement intake through specification, implementation, testing, review, documentation, and pull-request creation.

## Get Started

Register the marketplace and install the plugin:

```powershell
copilot plugin marketplace add Helfen-Industries/plugin-marketplace
copilot plugin install al-development-workflow@helfen-agent-marketplace
copilot plugin list
```

Start with a direct requirement, Azure DevOps work item, or GitHub issue:

```text
/al-development-workflow:workflow-work-package-begin <reference or requirement with acceptance criteria>
```

Examples:

```text
/al-development-workflow:workflow-work-package-begin https://dev.azure.com/example/BC/_workitems/edit/890
/al-development-workflow:workflow-work-package-begin Helfen-Industries/example-extension#42
/al-development-workflow:workflow-work-package-begin Add release handling to Service Orders. Acceptance criteria: ...
```

Azure DevOps retrieval and Azure Repos PR creation require the enabled `cosmo-bc-dev@agent-plugin-marketplace` plugin and its `ado-remote-mcp` server. Implementation also requires the repository's normal AL build and test tooling. New AL objects require the configured object-ID reservation tool.

On the first source-reference, implementation, or pull-request use, the workflow proposes `.github/copilot/work-package-context.json` and a matching `.gitignore` rule. The setup records a confirmed branch prefix such as `JHE`; direct requirements defer this repository context until implementation when necessary.

## Contents

### Delivery Commands

| Command                        | Purpose                                                                                                     | Successful state           |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------- | -------------------------- |
| `workflow-work-package-begin`  | Retrieve or normalize requirements, explore code, clarify decisions, and create the canonical specification | `Ready for implementation` |
| `workflow-spec-estimate`       | Create a reproducible Best, Expected, and Worst estimate from a ready specification                         | `Estimate ready`           |
| `workflow-spec-implement`      | Implement an approved specification with reserved object IDs, tests, and validation                         | `Ready for code review`    |
| `workflow-code-review`         | Simplify and review the complete implementation, repair unambiguous defects, and rerun validation           | `Ready for pull request`   |
| `workflow-pull-request-create` | Finalize documentation and create a confirmed GitHub or Azure Repos PR                                      | `Pull request created`     |

### Test And Maintenance Commands

| Command                      | Purpose                                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------------------ |
| `al-test-document-scenarios` | Create or synchronize stable Given/When/Then scenario documentation                        |
| `al-test-run-tdd`            | Run focused red-green-refactor cycles and prove the complete AL test app from Test Results |
| `simplify-code`              | Apply behavior-preserving simplification to a completed AL change                          |
| `simplify-codebase`          | Audit a repository or subsystem read-only for prioritized simplification opportunities     |
| `workflow-decisions-grill`   | Resolve user-owned implementation decisions and confirm shared understanding               |

The two AL test skills are available both as slash commands and for agent-initiated use when another workflow detects missing scenarios, test drift, failures, or required validation. Retrieval, context setup, AL-symbol access, specification generation, customer documentation, and provider-specific PR writes are hidden primitives invoked by the public workflows.

## Usage

### Standard Delivery

```text
/al-development-workflow:workflow-work-package-begin <requirement or source reference>
/al-development-workflow:workflow-spec-estimate plans/<requirement-id>-<slug>/technical-spec.md
/al-development-workflow:workflow-spec-implement plans/<requirement-id>-<slug>/technical-spec.md
/al-development-workflow:workflow-code-review plans/<requirement-id>-<slug>/technical-spec.md
/al-development-workflow:workflow-pull-request-create plans/<requirement-id>-<slug>/technical-spec.md
```

Estimation is optional. Scenario documentation and TDD are invoked by implementation when needed, or can be run directly:

```text
/al-development-workflow:al-test-document-scenarios <Task or spec, feature, feature code>
/al-development-workflow:al-test-run-tdd <scenario ID, test method, feature suite, or test app>
```

### Identity And Artifacts

For an assigned Azure DevOps Task, the Task remains the entry and traceability reference while its direct parent User Story owns the requirements and artifact identity. GitHub issues and direct requirements act as both entry and requirement source.

The workflow creates these artifacts when applicable:

- `{branch.prefix}/{entry-reference-number-or-NOID}-{1-to-3-word-plan-slug}`
- `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`
- `plans/{requirement-source-id-or-NOID}-{short-slug}/estimate.md`
- test-project scenario documentation with stable `{requirement-source-id}-{feature-code}-{sequence}` IDs
- `docs/features/{requirement-source-id-or-NOID}-{short-slug}.md`

### Repository And PR Routing

Work-item hosting and pull-request hosting are independent. Configure `defaultSource` for short work-item references, `branch.prefix` for local implementation branches, and `pullRequest.provider` as either `github` or `azure-devops`. The workflow never chooses a PR provider merely because the requirement came from Azure DevOps.

PR preparation synchronizes implemented-test documentation, creates non-technical customer documentation, reviews the documentation-only diff, and prepares a fixed PR description. It requests separate confirmation before commit, push, and external PR creation.

### Safety Gates

- Missing acceptance criteria or unresolved decisions block specification.
- A blocked or stale specification blocks implementation.
- Test failures, review findings, unrelated changes, or documentation drift block PR readiness.
- Read-only inspection does not require confirmation; file writes and external-system changes do.
- Provider adapters create exactly one confirmed PR and do not merge, approve, bypass policies, or update work-item state implicitly.

See [CHANGELOG.md](CHANGELOG.md) for release history.