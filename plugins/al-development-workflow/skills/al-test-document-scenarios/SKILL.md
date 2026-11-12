---
name: al-test-document-scenarios
description: Create or update Business Central AL test-scenario documents from the authoritative User Story and keep scenario IDs, titles, Given/When/Then steps, and AL test comments synchronized. Use when documenting test cases from an assigned Task, deriving scenarios from acceptance criteria, or repairing test-documentation drift.
argument-hint: <assigned Task or spec path, feature, and feature code>
user-invocable: true
disable-model-invocation: false
---

# Document AL Test Scenarios

Create the scenario specification; do not implement production or test code. Read [AL Test Conventions](references/al-test-conventions.md) and use the fixed [Scenario Template](assets/test-scenarios-template.md).

## Input

Require an authoritative requirement source, feature name, and short feature code. If the input is an assigned Azure DevOps Task, resolve its direct parent User Story and use that Story's ID, title, description, and acceptance criteria. Keep the Task ID as the entry reference. A ready canonical spec may provide both identities. Missing parent behavior is a product decision or retrieval gap, not documentation for the agent to invent.

The request authorizes creation or update of the matching scenario document. Preserve unrelated manual content and ask before replacing conflicting scenario intent.

## Process

1. Resolve the entry work item and requirement source. When given an Azure DevOps Task without a spec, apply [Get Azure DevOps Work Item](../workflow-azure-devops-work-item-get/SKILL.md) and require its direct parent User Story. Done when the Task remains traceable and the User Story is verified as the scenario identity and behavior source.
2. Locate the owning AL test project and its established test and documentation roots. Prefer repository conventions; otherwise use `src/test/<ownership area>/<feature path>` and `docs/test scenarios/<requirement-source-id>-<feature-name>` below the test project. Done when the target project, feature path, and Story-based document path are explicit.
3. Trace each parent User Story acceptance criterion to independently testable behavior. Keep Task-specific implementation constraints attributable but do not turn them into business acceptance criteria. Split scenarios when they require different When actions or can fail independently; group them by behavior, not implementation object. Done when every acceptance criterion has one or more scenario IDs and no scenario contains multiple When actions.
4. Allocate stable IDs as `<requirement-source-id>-<feature-code>-<sequence>`. When a canonical spec exists, adopt the scenario IDs, titles, and acceptance-criterion mapping from its Test scenarios section. Preserve existing IDs, continue the highest sequence, and never renumber merely to close gaps. Done when every scenario ID is unique in the feature document, matches the spec where one exists, and repository search finds no conflicting meaning.
5. Write or update `<Feature>TestScenarios.md` with the fixed template. Use the User Story title, description, and acceptance criteria for behavior; include the assigned Task only in entry metadata and traceability. Done when every scenario is independently executable and all template fields are complete.
6. When matching AL tests exist, compare the document ID and title with the first test-body comment `// [SCENARIO <ID>] <Title>` and verify ordered `[Given]`, one `[When]`, and `[Then]` comments. Report drift; update AL comments only when the user asked to synchronize existing tests. Done when every mapped test is synchronized or every mismatch is listed with its file and method.

## Output

Return the scenario document path, added or changed IDs, acceptance-criterion coverage, mapped AL tests, and unresolved gaps. End with `Ready for test implementation` only when the scenario specification is complete and synchronized.