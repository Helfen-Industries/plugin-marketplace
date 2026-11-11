---
name: workflow-work-package-begin
description: Start and orchestrate a Business Central AL work package from a direct requirement, Azure DevOps work item, or GitHub issue. Use whenever the user asks to begin a work package, provides requirements and acceptance criteria, or supplies a ticket, task, work item, or issue reference for specification.
argument-hint: <reference or requirement with acceptance criteria>
user-invocable: true
---

# Begin Work Package

Coordinate the workflow without duplicating the detailed logic of its phase skills.

## Safety boundary

Remain read-only throughout this workflow. Read-only shell commands are allowed without confirmation. Ask for explicit confirmation before modifying files or changing any external system.

## Workflow

1. Classify the input as a source reference or direct requirement. Use explicit input before configured defaults.
   - Treat an Azure DevOps URL, explicitly identified work item ID, GitHub issue URL, or `owner/repository#number` as a source reference.
   - Treat supplied Business Central requirements and measurable acceptance criteria as direct input. Accept an optional reference and use `NOID` when none is supplied.
   - Missing acceptance criteria for direct input are blocking; do not invent them.
   - Ask one concise question when the input is missing or could be either a reference or direct requirement.
   - Done when exactly one intake branch is selected with its required input, or intake is explicitly blocked.
2. For a source reference, read and validate `.github/copilot/work-package-context.json` for retrieval and implementation branch naming using [Work Package Context](../workflow-work-package-context-setup/references/work-package-context.md).
   - If it is missing or incomplete, apply [Setup Work Package Context](../workflow-work-package-context-setup/SKILL.md).
   - Obtain explicit confirmation before setup writes the file, then re-read it and continue the original request only when it is valid.
   - Done when the configuration needed to resolve the supplied reference and name its later implementation branch is valid, or setup is explicitly blocked. Skip this step for direct input; implementation will obtain missing branch context when needed.
3. For a source reference, identify and retrieve the source.
   - Use [Get Azure DevOps Work Item](../workflow-azure-devops-work-item-get/SKILL.md) for an Azure DevOps URL or an explicitly identified work item ID.
   - Use [Get GitHub Issue](../workflow-github-issue-get/SKILL.md) for a GitHub issue URL or `owner/repository#number` reference.
   - Use `defaultSource` only for a reference that does not identify its source.
   - When the entry item is an Azure DevOps Task, require retrieval of its direct parent User Story before normalization. Keep the Task as entry reference and use the Story as requirement source.
   - Done when one source skill has an unambiguous canonical reference, or retrieval is explicitly blocked.
   - Skip retrieval for direct input.
4. Normalize the package using [Normalized Work Package](references/normalized-work-package.md).
   - For direct input, set source type `direct` and preserve exact wording, attachments, links, and missing information.
   - Done when analysis can distinguish source facts, gaps, and concrete search targets without reopening the source.
5. Apply [Analyze Work Package](../workflow-work-package-analyze/SKILL.md). Done when its handoff completion condition is satisfied.
6. Apply [Explore Relevant Code](../workflow-code-explore/SKILL.md), regardless of apparent task size, with scope proportional to identified targets. Done when its exploration completion condition is satisfied.
7. Apply [Clarify Work Package](../workflow-work-package-clarify/SKILL.md). Recommendations are not answers. Done when its decision ledger is current and its completion state is explicit.
8. Stop while any implementation decision remains unresolved or shared understanding is unconfirmed. Done when the clarification completion gate is satisfied.
9. Apply [Create Implementation Plan](../workflow-spec-create/SKILL.md). Present the canonical spec path and its route (new spec, in-place update, or delta spec with its base) and obtain explicit confirmation before writing it. Ask before overwriting an existing spec containing unrelated changes. Done when the persisted spec satisfies its readiness gate, every planned behavior has a validation method, and the workflow ends `Ready for implementation`.

## Output

Respond in the user's language. End with the current workflow state: `Blocked by input`, `Blocked by setup`, `Blocked by retrieval`, `Blocked by clarification`, or `Ready for implementation`.

When ready, return the entry work item, requirement source, their relation, and canonical spec path. Estimation and implementation are separate explicit workflows that consume this artifact.

Do not implement the work package in this workflow.