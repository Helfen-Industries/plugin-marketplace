# AL Test Execution Protocol

## Execution surface

- Use the VS Code Testing panel to discover, run, and validate AL tests.
- Run the smallest scenario or method during red-green-refactor.
- Run the complete feature suite after focused green.
- Run all discovered tests with the built-in `testing.runAll` command before completion.
- Open the latest Test Results output with `testing.showMostRecentOutput` after a run.
- Do not substitute a generic terminal test command unless the repository explicitly defines it as the same AL test runner and result source.

## Evidence states

### Not red

The test cannot establish red when:

- AL compilation fails
- the app cannot publish
- Test Hub or TestRunnerHub cannot connect
- the test is absent from the Testing panel
- setup fails before the intended behavior is exercised

Repair the minimum scaffolding required to execute the behavioral assertion, then rerun.

### Valid red

Red requires all of the following:

- the test is discovered
- the test executes
- Test Results report a failure
- the message or AL call stack proves the documented missing or incorrect behavior caused the failure

### Valid green

Green requires Test Results evidence. Successful command invocation alone is insufficient. Treat every `<testFailure>` entry, failure message, and AL call stack as a failed test.

A complete successful run confirms:

- the test app built and published successfully
- Test Hub and TestRunnerHub connections were established
- every expected new test was discovered
- no test remains failed or undiscovered
- Test Results contain no `<testFailure>` entries

## Diagnosis order

For each failure, classify it before editing:

1. infrastructure or connection
2. compile or publish
3. discovery or metadata
4. fixture or setup
5. assertion or expected-error contract
6. production behavior
7. unrelated pre-existing failure

Use the failure message and first relevant project frame in the AL call stack to identify the controlling code path. Change one local cause, rerun the same focused test, and only widen scope after focused green.

## TDD integrity

- Do not implement production behavior before a valid red result for new behavior.
- Do not count a test that passed before the production change as red-green evidence.
- Do not delete, skip, weaken, or broaden assertions merely to get green.
- Do not make tests depend on execution order.
- Do not fold unrelated cleanup or unrelated failing tests into the behavior slice.