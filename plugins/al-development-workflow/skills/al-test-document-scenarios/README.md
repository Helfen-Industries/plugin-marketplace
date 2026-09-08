# Document AL Test Scenarios

Create or synchronize the feature scenario specification used by AL automated tests.

```text
/al-development-workflow:al-test-document-scenarios <assigned Task or spec path, feature, and feature code>
```

For an assigned Task, the skill retrieves its direct parent User Story. The Story supplies the title, description, acceptance criteria, folder identity, and stable scenario prefix; the Task remains entry metadata. The skill uses a fixed Given/When/Then format and explicit mappings to AL test codeunits and methods. It documents behavior but does not implement tests or production code.