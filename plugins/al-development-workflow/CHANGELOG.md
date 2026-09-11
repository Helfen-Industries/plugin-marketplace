# Changelog

All notable changes to this plugin are documented here.

## [0.9.0] - Unreleased

### Added

- Plugin README with installation, command catalog, end-to-end usage, artifact paths, provider routing, and safety gates.
- Repository-configured implementation branch prefixes and deterministic `{prefix}/{entry-number}-{plan-slug}` branch creation before implementation edits.
- Final findings-first AL code-review gate that includes focused simplification, complete diff review, defect repair, test-document synchronization, and full validation.
- Provider-neutral pull-request workflow with separate GitHub and Azure Repos write adapters.
- Story-based non-technical customer documentation covering delivered behavior, setup, permissions, usage, upgrade impact, and limitations.
- Fixed PR description template linking requirement source, assigned Task, customer documentation, implemented test scenarios, validation, and review evidence.

### Changed

- Specification and estimation artifacts now share `plans/{requirement-source-id-or-NOID}-{short-slug}` as their work-package folder, replacing separate `specs` and `estimates` roots.
- Work-package context setup now adds and verifies `/plans/` in the repository root `.gitignore` alongside its local context rule, and exposes the root `plans` directory in a confirmed repository `.code-workspace` file with JSONC-preserving edits.
- Successful implementation now hands off as `Ready for code review`; only the review workflow may produce `Ready for pull request`.
- Repository context now configures pull-request provider independently from work-item source, supporting Azure DevOps/Azure Repos legacy setups and Azure DevOps/GitHub current setups.
- Commit, push, and external PR creation are distinct confirmation boundaries.
- Pull-request preparation now performs a documentation-only final review before commit or push and returns implementation discrepancies to code review.
- Estimation now ends with the stable `Estimate ready` or `Blocked by estimation` workflow state.
- Automated-test estimation now uses an Expected baseline of `0.25 h` per mapped test case and counts shared fixture or posting setup once per coherent batch.
- Read-only shell inspection during work-package intake no longer requires confirmation; file and external-system writes remain confirmed boundaries.
- AL test scenario documentation and TDD explicitly remain available for agent-initiated invocation.

## [0.8.0] - Unreleased

### Changed

- Skill names now use domain-first namespaces so related commands and primitives group together in discovery.
- AL testing skills use the `al-test-*` prefix, reusable MCP-context primitives use `mcp-*`, simplification skills use `simplify-*`, and orchestration or source-adapter skills use `workflow-*` regardless of transport.
- Azure DevOps and GitHub retrieval now group together as `workflow-azure-devops-work-item-get` and `workflow-github-issue-get`; `mcp-al-symbols` remains grouped by its reusable MCP context.
- Workflow skills use subject-before-action names such as `workflow-work-package-begin` and `workflow-spec-implement`.
- All skill links, eval identities, command examples, and validator visibility rules now use the grouped names.

## [0.7.0] - Unreleased

### Changed

- Assigned Azure DevOps Tasks now remain workflow entry and traceability references while their direct parent User Stories provide business requirements and acceptance criteria.
- Canonical specification names, titles, and stable test-scenario IDs now use the authoritative requirement-source identity instead of the assigned Task ID.
- Test documentation, estimation, and implementation outputs preserve both identities and keep Task-specific implementation constraints attributable.
- Missing or inaccessible parent User Stories block specification and documentation instead of allowing Task descriptions to become inferred requirements.

## [0.6.0] - Unreleased

### Added

- Test-scenario documentation workflow with deterministic placement, stable requirement-source-prefixed IDs, fixed Given/When/Then structure, and AL comment synchronization.
- AL test execution workflow with strict red-green-refactor evidence, focused failure repair, feature-suite validation, and complete test-app verification through VS Code Test Results.

### Changed

- Spec implementation now delegates scenario documentation and executable AL test loops to the dedicated testing workflows.

## [0.5.0] - Unreleased

### Changed

- Technical-spec estimates now classify the source and each implementation item before calculating effort.
- The estimate artifact now reports Best, Expected, and Worst values for a fixed set of delivery categories.
- Automated tests, manual validation, test documentation, solution documentation, dependent-app work, and defect analysis are estimated separately.
- Waiting time and token use remain informational, while fixed-price risk is applied once and kept separate from effort scenarios.

## [0.4.0] - Unreleased

### Changed

- `workflow-work-package-begin` now accepts direct requirements with measurable acceptance criteria as well as Azure DevOps and GitHub references.
- Direct input bypasses repository source setup and ticket retrieval, then joins the shared analysis, exploration, clarification, and canonical-spec pipeline.
- The separate `bc-to-spec` command was removed in favor of one discoverable work-package entry point.

## [0.3.0] - Unreleased

### Added

- Repository-owned work-package source configuration with Azure DevOps and GitHub defaults.
- Setup workflow that infers repository metadata, confirms changes, and writes configuration idempotently.
- Shared normalized work-package handoff for source retrieval skills.
- Reusable grilling primitive with decision frontiers, fact discovery, and confirmation gates.
- Reusable AL Symbols MCP primitive with synchronous package loading, project selection, and empty-index recovery.
- User-invocable AL implementation simplification workflow focused on readability, maintainability, behavior preservation, and removing AI slop before pull-request creation.
- Read-only repository-wide simplification audit with evidence-backed findings, impact and risk ranking, and bounded follow-up batches.
- Shared simplification lens used by implementation cleanup and repository auditing.
- Direct-requirement intake that converges on the work-package analysis, exploration, clarification, and specification pipeline.
- Canonical fixed-section technical specification shared by planning, estimation, and implementation.
- Separate explicit workflows for AI-assisted estimation and spec-driven AL implementation.
- Behavioral eval suites for every skill.

### Changed

- Work-package orchestration now verifies setup and resumes the original request after setup succeeds.
- Clarification now delegates interview mechanics to the grilling primitive.
- Workflow skills now define explicit input contracts, checkable completion conditions, and distinct setup, retrieval, and clarification failure states.
- Eval coverage now exercises incomplete source data and attempts to bypass setup or shared-understanding confirmation.
- Supporting workflow skills are hidden from the slash-command menu; `workflow-work-package-begin` remains the primary entry point and `grilling` remains independently invocable.
- Work-package setup now proposes and verifies an idempotent root `.gitignore` rule for repository-local context, while reporting separately when an existing file is already tracked.
- Azure DevOps retrieval now resolves the external `ado-remote-mcp` WIT tools from `cosmo-bc-dev`, supports lazy remote startup, and reports dependency, connection, and authentication failures distinctly.
- Implementation planning now persists the canonical technical spec and excludes effort, pricing, token estimates, and new object-ID assignment.

## [0.1.0] - Unreleased

### Added

- Initial Agent Plugins 1.0 manifest.
- Work-package orchestration from Azure DevOps work items and GitHub issues.
- Separate analysis, code exploration, clarification, and implementation-planning skills.