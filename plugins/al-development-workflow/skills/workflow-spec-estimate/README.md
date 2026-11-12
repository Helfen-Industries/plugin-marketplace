# Estimate Technical Spec

Explicit estimation workflow consuming a canonical ready technical specification.

```text
/al-development-workflow:workflow-spec-estimate <path to canonical spec>
```

It writes a separate, fixed-schema estimate artifact of the developer's active human effort for AI-assisted delivery. Implementation items receive a delivery-complexity class with start values. Automated tests are estimated per test batch rather than per case, and alignment, review, BC validation, build, and PR work share one S, M, or L delivery allowance. Bug analysis, dependent apps, extra companies, migrations, and similar work appear only as triggered additions. Best and Worst differ from Expected only through named, evidenced conditions.

Start values are calibrated with measured actuals from the user-level calibration log written by `workflow-actuals-record`. Agent runtime, waiting time, and fixed-price risk stay outside the effort totals.

The canonical input is `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`; the estimate is written beside it as `estimate.md`.
