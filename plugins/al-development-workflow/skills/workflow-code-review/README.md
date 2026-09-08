# Review AL Implementation

Run the final local review gate after implementation and before pull-request preparation.

```text
/al-development-workflow:workflow-code-review <canonical spec path and implemented change>
```

The workflow combines behavior-preserving simplification with a findings-first review of the complete AL change, repairs unambiguous in-scope defects, synchronizes test documentation, and proves the final test and build state.