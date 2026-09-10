# Estimate Technical Spec

Explicit estimation workflow consuming a canonical ready technical specification.

```text
/al-development-workflow:workflow-spec-estimate <path to canonical spec>
```

It writes a separate, fixed-schema estimate artifact. Each implementation item receives a delivery-complexity class, and every effort category reports Best, Expected, and Worst values. Automated tests, manual validation, test documentation, and solution documentation remain visible rather than being hidden inside development. Active effort, waiting time, commercial effort, token use, and fixed-price risk stay distinct.

The canonical input is `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`; the estimate is written beside it as `estimate.md`.
