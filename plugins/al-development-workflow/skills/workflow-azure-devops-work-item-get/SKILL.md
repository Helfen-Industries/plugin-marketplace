---
name: workflow-azure-devops-work-item-get
description: Retrieve an Azure DevOps work item and its implementation-relevant context through the external ado-remote-mcp server. Use for Azure DevOps URLs, work item IDs explicitly identified as Azure DevOps, ADO tickets, backlog items, bugs, tasks, or user stories.
user-invocable: false
---

# Get Azure DevOps Work Item

## Input

Require an Azure DevOps work item URL or an ID with enough organization and project context to resolve it unambiguously.

Read [Work Package Context](../workflow-work-package-context-setup/references/work-package-context.md) for repository defaults and resolution precedence.

## MCP dependency

Use the `ado-remote-mcp` server contributed by the separately installed `cosmo-bc-dev` plugin. The server may be installed and enabled without an active connection.

Before retrieval, discover or resolve the Azure DevOps Work Item Tracking read tool from `ado-remote-mcp`, such as `ado-remote-mcp/wit_work_item`. Tool discovery or the first tool call starts the remote connection when needed; do not run a shell command or invent a separate server-start operation. Done when the WIT read tool is available for invocation or a concrete discovery, connection, or authentication failure has been returned.

## Procedure

1. Resolve organization, project, and entry work item ID from explicit input, then valid repository defaults. Done when the entry reference is unambiguous or the exact missing value has been requested.
2. Use `ado-remote-mcp` Work Item Tracking read operations to retrieve the entry item with fields and relations.
	- If the entry type is Task, follow its direct parent relation and retrieve that item with fields, relations, and acceptance criteria.
	- Require the direct parent to be a User Story. If it is missing, inaccessible, or another type, record the exact retrieval or hierarchy gap and stop before analysis rather than treating the Task description as the business requirement.
	- If the entry item is a User Story or Bug, use it as both entry item and requirement source.
	- Done when both identities and their relationship are verified, or retrieval is explicitly blocked.
3. Retrieve comments, attachments, and linked items when they affect parent requirements, acceptance criteria, or Task-specific implementation constraints. Keep parent content and entry Task content attributable to their source. Done when contradictions and inaccessible content are explicit.
4. Record inaccessible attachments as links without inventing their content. Return [Normalized Work Package](../workflow-work-package-begin/references/normalized-work-package.md). Done when its completion condition is satisfied or every unavailable field is named.

## Failure handling

- If the WIT tool is not initially visible, perform tool discovery for `ado-remote-mcp` before declaring it unavailable.
- If the contributing plugin or server is unavailable after discovery, state that `cosmo-bc-dev` must be installed and enabled, then ask the user to provide the work item content as a fallback.
- If the remote server returns a connection or authentication failure, report that concrete failure and stop; do not replace it with a generic missing-tool message or alternate credentials.
- If access is denied or the item does not exist, report that result without trying alternate credentials.
- Never update the work item, add comments, or change its state.

End an unresolved or failed retrieval with `Blocked by retrieval` and the minimum information needed to resume.