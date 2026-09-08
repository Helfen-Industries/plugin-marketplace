# Run AL Tests TDD

Run and repair AL tests through a strict VS Code Testing red-green-refactor loop.

```text
/al-development-workflow:al-test-run-tdd <scenario ID, test method, feature suite, or test app>
```

The skill distinguishes behavioral red from compile, publish, connection, and discovery failures. It reports green only from Test Results evidence, then verifies the focused test, feature suite, and complete test app.