---
name: al-test-run-tdd
description: Run, diagnose, and fix Business Central AL automated tests in a strict red-green-refactor loop using VS Code test discovery and Test Results evidence. Use when implementing a documented scenario, repairing failing AL tests, validating a feature suite, or proving a test app is green.
argument-hint: <scenario ID, test method, feature suite, or test app>
user-invocable: true
disable-model-invocation: false
---

# Run AL Tests TDD

Own the executable test loop; do not invent scenario behavior. Read [AL Test Execution Protocol](references/al-test-execution-protocol.md). When a scenario specification is missing or incomplete, apply [Document AL Test Scenarios](../al-test-document-scenarios/SKILL.md) before implementing behavior.

## Input

Require one scenario ID, test method, feature suite, or test app plus its expected behavior. For new behavior, require a documented scenario with measurable Given/When/Then outcomes. For an existing failure, use the current test and the latest `runTests` output as evidence.

## Process

1. Locate the owning app and test project, verify project dependencies, and identify the scenario document, test codeunit, feature library, production surface, and repository instructions. Reserve an object ID before creating any AL object; never guess one. Done when the focused test target and strongest available execution route are explicit.
2. Ensure the test follows the documented scenario: matching `// [SCENARIO <ID>] <Title>`, ordered `[Given]`, exactly one `[When]`, and `[Then]` comments. Use feature libraries for setup, standard Microsoft libraries for standard Business Central behavior, `Library Assert` for assertions, and labels for expected errors. Done when the test compiles conceptually against the intended public contract without changing scenario intent.
3. Make the test discoverable in the VS Code Testing panel. A compile, publish, connection, or discovery failure is infrastructure or scaffolding failure, not red. Add only the minimum public contract or scaffolding needed for a behavioral assertion to execute. Done when the named test appears in Testing and can run.
4. Run the smallest relevant test from the Testing panel. Open Test Results and inspect the failure message and AL call stack. Red is established only when the test fails for the intended missing or incorrect behavior. If it passes before the production change, strengthen the assertion or report that the scenario is already satisfied. Done when the observed red reason matches the scenario.
5. Implement the smallest production change that addresses the observed behavioral failure. Rerun the same focused test and inspect Test Results after every change. Repair local compile, publish, setup, assertion, and production defects one at a time; do not batch speculative fixes. Done when the focused test has no failure entry and its result is Passed.
6. Refactor only the touched behavior while rerunning the focused test. Then run the complete feature suite and inspect Test Results. Diagnose failures from messages and call stacks; distinguish regressions from unrelated pre-existing failures and do not weaken assertions to obtain green. Done when the focused and feature tests pass or every external blocker is evidenced.
7. Run all discovered tests in the test app with `testing.runAll`, open output with `testing.showMostRecentOutput`, and verify the complete protocol. Done when the app built and published, Test Hub and TestRunnerHub connected, every expected new test was discovered, and Test Results contain no `<testFailure>` entries.

## Output

Report:

- scenario IDs and tests exercised
- red evidence and why it matched the intended behavior
- production and test files changed
- focused, feature-suite, and full-app results
- discovered test count or named discovery evidence
- remaining unrelated failures or infrastructure blockers

Never report success from command invocation alone. End with `AL test app green` only when the final Test Results output satisfies the complete protocol.