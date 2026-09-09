# Implement Technical Spec

Explicit implementation workflow consuming one ready canonical Business Central technical specification.

```text
/al-development-workflow:workflow-spec-implement <path to canonical spec>
```

It creates or resumes `{configured-prefix}/{entry-number}-{1-to-3-word-plan-slug}` before any implementation edit, reserves IDs for new AL objects, implements in dependency order, adds mapped tests, and validates incrementally. A successful run ends `Ready for code review`; review and PR creation remain separate gates.
