---
name: workflow-spec-estimate
description: Estimate a ready Business Central technical specification as active human effort for AI-assisted delivery. Classify implementation items, test batches, and a delivery allowance, derive Best, Expected, and Worst from named conditions, calibrate start values with measured actuals, and keep agent runtime and fixed-price risk separate. Use only when explicitly asked to estimate a canonical spec.
argument-hint: <path to canonical technical spec>
user-invocable: true
disable-model-invocation: true
---

# Estimate Technical Spec

Estimate from the canonical spec without changing it. Read its [Technical Specification Contract](../workflow-spec-create/references/technical-spec-contract.md), this skill's [Estimation Model](references/estimation-model.md), and use the fixed [Estimate Template](assets/estimate-template.md).

## Input

Require the path to one canonical technical spec at `plans/{requirement-source-id-or-NOID}-{short-slug}/technical-spec.md`. The explicit invocation authorizes creation or update of `estimate.md` in that same plan folder; ask before overwriting unrelated manual changes. If the spec uses a legacy location, return the required canonical path and route migration through `workflow-spec-create`; do not create a split artifact set.

## Process

1. Validate the spec structure, readiness, Object catalog, Ordered implementation plan, test scenarios, assumptions, and risks. Treat `Object inventory` in a spec written before the rename as its Object catalog. Done when the spec is `Ready for implementation` or the exact reason a reliable estimate is impossible is reported.
2. Read the calibration log as the model specifies, without asking for a missing path. Done when each category has a calibration method, factor, usable record count, and log path, or an uncalibrated state with its reason.
3. Classify the requirement source as User story, Bug, or Change request. Derive implementation items from the Ordered implementation plan and classify each one. Keep the assigned entry Task for traceability and include its implementation constraints, but do not classify the Task as the business requirement when the spec names a parent User Story. Done when every plan step is an item, part of Automated tests, or covered by the delivery allowance, and every item has one class, concrete drivers, and spec or workspace evidence.
4. Group the spec's test scenarios into test batches, select the delivery allowance size, and list only triggered conditional additions. Done when every batch has a type and setup basis, the allowance names its deciding criteria, and every addition cites its trigger.
5. Derive Best and Worst only from the model's named conditions, each citing spec or workspace evidence. Done when every value that differs from Expected names its condition and no percentage spread is used.
6. Apply calibration per category and sum the four human-effort categories for each scenario. Report agent runtime and waiting time outside the totals. Done when every total can be reproduced from the start values and calibration factors without double-counted uncertainty.
7. Determine whether a fixed-price scenario is supportable from scope stability and residual uncertainty. Apply the risk surcharge once when requested and supportable; never add both hidden contingency and a surcharge. Done when eligibility, surcharge, and commercial total are visibly distinct.
8. Ensure the repository-root `plans` directory and target plan folder exist, then write `estimate.md` there without modifying the spec. Do not create separate `specs` or `estimates` directories. Done when the estimate is colocated with the canonical spec and every template section, start value, condition, calibration statement, and arithmetic check is present.

Do not add implementation detail missing from the spec and do not resolve open decisions through estimation. A blocked spec may receive only a preliminary range clearly marked unreliable; it must not receive a fixed-price total.

Return the estimate path, Best / Expected / Worst human effort, calibration state, assumptions, and confidence. End with `Estimate ready` only when another reviewer can reproduce the classification and estimate from the same spec and calibration log. Otherwise end `Blocked by estimation` with the exact readiness, evidence, or calculation gap. A preliminary range from a blocked spec remains `Blocked by estimation`. After delivery, [Record Delivery Actuals](../workflow-actuals-record/SKILL.md) compares the actual active time with this estimate and feeds the calibration log.
