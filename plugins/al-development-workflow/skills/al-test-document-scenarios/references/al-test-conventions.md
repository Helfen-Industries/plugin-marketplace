# AL Test Conventions

## Placement

- Place automated AL test objects below `src/test`.
- Preserve the application feature path from its ownership area, such as `Own/<Feature>` or `Microsoft/<Area>/<Feature>`.
- Do not reproduce company and product namespace folders in the test path.
- Test AL files do not declare a namespace.
- Keep feature test codeunits, fixture tables, providers, and libraries together. Put only genuinely shared utilities in a shared test folder.
- Use `src/test/<ownership area>/<feature path>/<ObjectName>.<ObjectType>.al` when the repository has no stronger convention.

## Files and objects

- Follow `<ObjectNameExcludingAffix>.<FullObjectType>.al`.
- Name test codeunits `<Feature> Tests` and files `<Feature>Tests.Codeunit.al`.
- Name feature libraries `<Feature> Test Library` and files `<Feature>TestLibrary.Codeunit.al`.
- Name providers and fixtures after their role.
- Use the app affix.
- Reserve IDs from the test app's configured range before creating AL objects; never guess an ID.

## Scenario documents

- Place documents below `docs/test scenarios/<requirement-source-id>-<feature-name>` in the test project unless the repository defines another root.
- Name the document `<Feature>TestScenarios.md`.
- Use the parent User Story ID, not the assigned Task ID, in `<requirement-source-id>-<feature-code>-<sequence>`, for example `14734-TL-001`.
- Keep the assigned Task ID and canonical reference in document metadata as the workflow entry point.
- Group by behavior while keeping each scenario independently testable.
- Treat the document as the source specification for automated test methods.

## AL synchronization

- Name test methods `Given..._When..._Then...`.
- Begin each test body with `// [SCENARIO <ID>] <Title>` matching the scenario document.
- Follow with ordered `[Given]`, exactly one `[When]`, and one or more `[Then]` comments.
- Keep tests isolated and independent of execution order.
- Create feature data through the feature test library and prefer standard Microsoft libraries for standard records and posting.
- Use `Library Assert`; store expected errors in labels rather than inline literals.
- Add XML documentation only to public reusable test-library procedures when it clarifies their contract.