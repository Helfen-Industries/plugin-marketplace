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

Code exploration uses the AL Symbols MCP server for project dependencies. The optional [BC Observatory](https://waldo1001.github.io/waldo.BCObservatory/mcp/) (`npx -y bc-observatory@latest`) and BC Code Atlas (`https://bc-code-atlas.stefanmaron.dev/mcp`) servers add Microsoft object history, localizations, and base-app procedure bodies; without them, exploration falls back to AL Symbols and Microsoft Learn.

When the `obsidian-vault` plugin is installed, `workflow-work-package-begin` loads the customer's fact sheet, decisions in force, concepts, and open items from the personal knowledge vault through `vault-customer-context`. The brief is labeled context for analysis and clarification and never replaces the requirement source; without the plugin the workflow is unchanged.

On the first source-reference, implementation, or pull-request use, the workflow proposes `.github/copilot/work-package-context.json` and matching `.gitignore` rules. A natural-language request such as `Set up the AL workflow` invokes the same repository-context setup without inspecting or building the AL application. The setup records a confirmed branch prefix such as `JHE`; direct requirements defer this repository context until implementation when necessary. When the repository uses a `.code-workspace` file, setup also proposes adding the root `plans` directory as a workspace folder while preserving the file's JSONC content. Rerunning setup reuses complete persisted values and checks only missing or conflicting repository evidence.

## Contents

### Delivery Commands

| Command                        | Purpose                                                                                                     | Successful state           |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------- | -------------------------- |
| `workflow-work-package-begin`  | Retrieve or normalize requirements, explore code, clarify decisions, and create the canonical specification | `Ready for implementation` |
| `workflow-spec-estimate`       | Estimate active human effort from a ready specification, calibrated by recorded actuals                     | `Estimate ready`           |
| `workflow-spec-implement`      | Implement an approved specification with reserved object IDs, tests, and validation                         | `Ready for code review`    |
| `workflow-code-review`         | Simplify and review the complete implementation, repair unambiguous defects, and rerun validation           | `Ready for pull request`   |
| `workflow-pull-request-create` | Finalize documentation, create a confirmed GitHub or Azure Repos PR, and capture active time                | `Pull request created`     |
| `workflow-actuals-record`      | Record or correct the developer's active time and compare it with the estimate                              | `Actuals recorded`         |

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

### Estimation And Actuals

Estimates report the developer's active human effort for AI-assisted delivery: classified implementation items, automated tests per test batch, one S, M, or L delivery allowance for alignment, review, BC validation, build, and PR, and only triggered additions. Best and Worst follow named, evidenced conditions. Agent runtime is informational.

The class and allowance values are start values. After PR creation, the workflow asks one skippable question about your active time. You can also record or correct it later:

```text
/al-development-workflow:workflow-actuals-record plans/<requirement-id>-<slug> <hours>
```

Actuals are written to `actuals.md` and upserted into a JSON Lines calibration log outside every repository. Its absolute path is configured as `calibrationLog` in `~/.copilot/al-development-workflow/settings.json`; the first recording proposes a default and asks for confirmation. From three usable records onward, new estimates scale their start values by the measured median ratio. Commit and PR timestamps are never treated as effort.

### Identity And Artifacts

For an assigned Azure DevOps Task, the Task remains the entry and traceability reference while its direct parent User Story owns the requirements and artifact identity. GitHub issues and direct requirements act as both entry and requirement source.

The workflow creates these artifacts when applicable:

- `{branch.prefix}/{entry-reference-number-or-NOID}-{1-to-3-word-plan-slug}`
- `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`
- `plans/{requirement-source-id-or-NOID}-{short-slug}/estimate.md`
- `plans/{requirement-source-id-or-NOID}-{short-slug}/actuals.md`
- test-project scenario documentation with stable `{requirement-source-id}-{feature-code}-{sequence}` IDs
- `docs/features/{requirement-source-id-or-NOID}-{short-slug}.md`

### Technical Specification

`technical-spec.md` is organized in three parts:

- **Part A - Concept** for consultants and reviewers: summary, initial situation, target process with a required Mermaid diagram, scope, and key decisions on about two pages.
- **Part B - Technical design** for developers and agents: solution design, an Object catalog with one row per AL object of any type (including enum, report, and permission set extensions, API pages, install and upgrade codeunits, and test codeunits), object details in catalog order, affected cross-cutting concerns, test scenarios, and the ordered implementation plan.
- **Part C - Appendix**: requirements with traceability, the full decision log, readiness self-review, and version history.

A completeness gate requires every created or changed object, field, enum value, and other member to appear in the Object catalog and every catalog row to be covered by an implementation step. For the same requirement source, a change updates an unimplemented spec in place with a new version, while a change to an implemented spec creates a separate delta spec in its own plan folder that links its base specification. A change from a different requirement source, such as a later direct requirement, always gets its own spec and is never appended to another requirement's spec.

Part A currently uses a generic concept structure; alignment with the Success by Design (SbD) concept template is still open.

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