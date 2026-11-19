# AL Container Publish And Test Run

Infrastructure layer under the [AL Test Execution Protocol](al-test-execution-protocol.md). A failure here is never red.

## Publish target

Publish only to the `launch.json` configuration the user named or the repository's single development configuration. Ask when several exist or the target could be a production environment. Done when the target configuration is explicit.

## Tool chain

Run in this order; stop at the first failing step and diagnose it before continuing.

1. Open the `app.json` of the project to build; AL tools act on the project of the focused `app.json`.
2. Download symbols (`al_downloadsymbols`) for new dependencies or "symbol not found".
3. Build (`buildAlPackage` or `al_build`) and read the diagnostics.
4. Publish (`al_publish` with `debug=false`, `skipbuild=true`). Never start the debugger for a test run.
5. Verify the publish (next section).
6. Run tests through the Testing panel, or `runTests` when the host exposes it, narrowed to the focused files or test names first.

Publish the app before its test app. Done when the verified published version matches the build and the run produced Test Results.

## Verify the publish

`al_publish` output never proves success. Require one of:

- Extension Management (page 2500) shows the built version.
- The changed behavior is visible in the web client.

If the container holds a higher or pipeline-built version, the local build is not taken over. Report it; do not change `app.json` versions to force a publish. A stalled publish may wait on a credential prompt in VS Code: never type credentials, ask the user to publish through the launch configuration, then verify again. Done when the version or behavior is observed, not assumed.

## Runner support

Before the first run on a target, check that Test Hub and TestRunnerHub connect. A target without VS Code test-runner support is an infrastructure blocker; report it instead of retrying. Published extensions end open web client sessions, so a following browser step must sign in again.

## Stale build errors

Symptom: errors in unchanged files or for facts the file content disproves, such as an ID-range error on an object well inside its range.

1. Read the file and confirm whether the error is real.
2. Try `al_build` with `scope=current`.
3. If it persists, ask the user to run `Developer: Reload Window`.

Done when the diagnostics match the file content or the user's reload resolved them; do not hunt a phantom error beyond these steps.

## Known failure causes

Change one cause per rerun.

| Symptom | Cause and fix |
| --- | --- |
| Date formula `'0D'` invalid, only in a localized session | Use angle brackets: `'<0D>'`, `'<+10D>'` |
| Page test fails on a missing setup record | Add an ensure-setup helper to the feature test library and call it in the test |
| Lowered-permission test has no effect | Start permission logging and set the outside-O365 scope in the library |
| Passes alone, fails in the suite | A foreign test with `Commit()` left global setup values behind; set the test's own values unconditionally, not only when empty |
| Fails only on a fresh company | A foreign app adds required setup fields; do not report done after the first fix |
| FlowField stays 0 without error | `SetLoadFields` never calculates FlowFields; use `CalcFields` or `SetAutoCalcFields` |
| Event subscriber analyzer error LC0065 only in the pipeline | Match the publisher's `var` parameters; a local build without LinterCop hides it |
