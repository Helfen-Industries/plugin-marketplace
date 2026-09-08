# Code Simplify

User-invocable post-implementation review for preparing AL changes before pull-request creation.

Invoke it with:

```text
/al-development-workflow:simplify-code <implemented AL change or files to simplify>
```

The workflow reviews the implementation diff, removes evidence-backed complexity and AI-generated clutter, preserves intended behavior, and reruns focused validation. It deliberately excludes feature changes, broad redesigns, dependency upgrades, and unrelated cleanup.
