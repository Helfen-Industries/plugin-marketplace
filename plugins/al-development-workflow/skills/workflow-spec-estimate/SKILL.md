---
name: workflow-spec-estimate
description: Estimate a ready Business Central technical specification with classified work items and reproducible Best, Expected, and Worst effort scenarios. Separately show development, tests, documentation, active delivery effort, and fixed-price risk. Use only when explicitly asked to estimate a canonical spec.
argument-hint: <path to canonical technical spec>
user-invocable: true
disable-model-invocation: true
---

# Estimate Technical Spec

Estimate from the canonical spec without changing it. Read its [Technical Specification Contract](../workflow-spec-create/references/technical-spec-contract.md), this skill's [Estimation Model](references/estimation-model.md), and use the fixed [Estimate Template](assets/estimate-template.md).

## Input

Require the path to one canonical technical spec. The explicit invocation authorizes creation or update of its derived estimate at `estimates/{spec-basename}.md`; ask before overwriting unrelated manual changes.

## Process

1. Validate the spec structure, readiness, object inventory, implementation steps, test mapping, assumptions, and risks. Done when it is `Ready for implementation` or the exact reason a reliable estimate is impossible is reported.
2. Classify the requirement source as User story, Bug, or Change request and classify each implementation-plan item using the estimation model. Keep the assigned entry Task as traceability and include its implementation constraints, but do not classify the Task as the business requirement when the spec names a parent User Story. Do not classify object count as complexity. Done when every item has one size class, concrete drivers, and traceable spec or workspace evidence.
3. Identify measured delivery data for genuinely comparable recent work when available. Otherwise use the model's item classes, activity calibrations, and AI-assisted object ranges. Done when every calibration source and deviation is explicit.
4. Estimate all fixed categories in Best, Expected, and Worst scenarios. Keep analysis, dependent-app work, automated tests, manual validation, test documentation, and solution documentation visible; use explicit zeroes instead of omitting categories. Estimate related code and tests in coherent batches rather than multiplying every procedure or scenario as independent manual work. Done when every row has three values and a one-line basis.
5. Reconcile active implementation time, commercial base effort, and scenario totals. Treat waiting for feedback, releases, or test data as elapsed time rather than effort. Keep token consumption informational and outside hour totals. Done when all totals can be reproduced from the rows without double-counted uncertainty.
6. Determine whether a fixed-price scenario is supportable from scope stability and residual uncertainty. Apply the risk surcharge once when requested and supportable; never add both hidden contingency and a surcharge. Done when eligibility, surcharge, and commercial total are visibly distinct.
7. Write the fixed estimate artifact without modifying the spec. Done when every template section, classification, scenario value, assumption, and arithmetic check is present.

Do not add implementation detail missing from the spec and do not resolve open decisions through estimation. A blocked spec may receive only a preliminary range clearly marked unreliable; it must not receive a fixed-price total.

Return the estimate path, Best / Expected / Worst totals, assumptions, and confidence. End with `Estimate ready` only when another reviewer can reproduce the classification and estimate from the same spec and stated calibration. Otherwise end `Blocked by estimation` with the exact readiness, evidence, or calculation gap. A preliminary range from a blocked spec remains `Blocked by estimation`.
