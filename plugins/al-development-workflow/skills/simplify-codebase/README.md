# Codebase Simplify Audit

User-invocable, read-only repository audit for identifying maintainability improvements and AI-generated clutter in AL codebases.

Invoke it with:

```text
/al-development-workflow:simplify-codebase <repository, app, or subsystem scope>
```

The audit produces evidence-backed, prioritized findings and bounded implementation batches. It does not modify files; selected findings can be implemented with `/al-development-workflow:simplify-code`.
