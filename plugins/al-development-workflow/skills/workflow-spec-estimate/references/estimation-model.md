# Estimation Model v2

Estimate the active human time one AL developer spends delivering a ready spec with an AI coding agent. Every hour value in this reference is a start value. Measured actuals from the calibration log adjust these values as described under Calibration.

## Units

- **Human effort** is the developer's active time: approving the spec, steering and correcting the agent, making decisions, reviewing, validating in Business Central, and preparing the PR. It is the commercial base effort.
- **Agent runtime** is the wall time the agent works without the developer, including generation, builds, and test runs. It is informational only.
- **Waiting time** covers feedback, environment, test data, release, and reviewer lead time. It is reported separately and is never effort.

Calculate row values to two decimals. Round each scenario total half up to the nearest 0.25 h, and show the unrounded sum in the arithmetic check. Report only AI-assisted human effort; do not add a separate value for development without AI.

## Classification

Classify the requirement source as `User story`, `Bug`, or `Change request`. An assigned Task remains the entry reference and may add implementation constraints. Its type and description do not replace the classification or requirements of the parent User Story.

Derive implementation items from the spec's **Ordered implementation plan**. By default, one plan step is one item. Merge steps that change the same objects within one validation cycle, and split a step only when it serves unrelated acceptance criteria. A step that only documents or automates tests belongs to Automated tests. A step that only builds, validates, or checks regressions belongs to the delivery allowance. Classify each item by delivery complexity, never by object count.

Item effort is the developer's time to instruct the agent, read and correct its output for that item, and resolve item-level compiler and analyzer findings.

| Class   | Typical scope                                                                               |  Low | Default | High |
| ------- | ------------------------------------------------------------------------------------------- | ---: | ------: | ---: |
| Trivial | Caption, visibility, filter, permission grant, or a similar declarative change              | 0.10 |    0.15 | 0.25 |
| Small   | One field across table and page, one subscriber, or focused local logic                     | 0.25 |    0.40 | 0.50 |
| Medium  | New calculation, report, or coordinated change across objects                               | 0.50 |    1.00 | 1.50 |
| Large   | New process, posting or warehouse logic, journal flow, algorithm, migration, or upgrade code | 1.50 |    2.50 | 4.00 |

Expected uses Default. Best and Worst differ from Default only through the scenario conditions below.

## Automated tests

Estimate test batches, not test cases. A batch is a set of scenarios that the agent generates and runs together on one shared setup, usually one test codeunit or one feature suite. Start another batch only for a distinct fixture family or a separate test app. Scenario count, test procedures, assertions, and reruns never multiply hours; they affect agent runtime only.

| Type | Batch setup                                                                                          | Expected |
| ---- | ---------------------------------------------------------------------------------------------------- | -------: |
| A    | Existing fixtures or test libraries cover the complete setup, including any posting or warehouse setup |   0.25 h |
| B    | New fixtures or helpers are required, without new posting, warehouse, valuation, or tracking setup    |   0.50 h |
| C    | New posting, warehouse, valuation, or item-tracking setup is required                                 |   1.00 h |

Select the type by the setup that must still be built, not by the business area under test.

Batch effort covers reviewing generated tests, correcting setup, and interpreting failures. Use `0 h` with a reason when the spec requires no automated tests. Manual-only scenarios are validated within the delivery allowance.

## Delivery allowance

One allowance replaces separate rows for alignment, manual validation, test evidence, build and translations, code review, PR, and ordinary direct corrections. It covers spec approval and clarifications during implementation, code review of the complete diff, manual validation in Business Central, test evidence, build and translation checks, review of generated customer documentation, PR preparation, and one review-response round.

| Size | Select when                                                                                                                                                          | Expected |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------: |
| S    | At most two items, no new translatable text, and at most one validation path without posting or warehouse documents                                                   |   0.75 h |
| M    | Neither S nor L applies                                                                                                                                              |   1.50 h |
| L    | Seven or more items, posting, warehouse, or valuation behavior to validate, more than three validation paths, or more than one company or localization                |   3.00 h |

A validation path is one distinct business entry point, such as an action, document type, or posting routine. Variants of the same entry point count once.

## Conditional additions

Add only lines whose trigger is supported by the spec or verified workspace evidence. Otherwise write `None triggered`.

| Trigger                                                                           | Expected |
| --------------------------------------------------------------------------------- | -------: |
| Bug cause needs reproduction; source is available                                 |   0.50 h |
| Bug cause needs reproduction; only dependency symbols are available               |   1.00 h |
| Bug analysis needs a posting run or representative data analysis                  |   1.50 h |
| Owned dependent app needs an event, version, or release change                    |   0.50 h |
| Owned shared app change affects other consumers                                   |   1.00 h |
| Third-party request plus temporary workaround                                     |   1.50 h |
| Each additional company, language, or localization to validate                    |   0.25 h |
| Second repository and PR cycle                                                    |   0.50 h |
| Migration or upgrade validated on representative data                             |   1.00 h |
| Each requested solution document beyond customer documentation and test evidence  |   0.50 h |

A bug cause already supported by current code evidence triggers no analysis line. The three bug-analysis lines are alternative levels; use only the highest applicable one. External release lead time is waiting time.

## Scenario conditions

Best and Worst equal Expected unless a named condition applies. Each condition cites spec or workspace evidence: a remaining risk, an assumption, a confirmed decision, or a verified fact. Never derive a scenario as a percentage of Expected, and never add a condition for a risk that the spec places out of scope.

| ID         | Scenario | Applies to | Condition                                                                                                | Effect                                    |
| ---------- | -------- | ---------- | -------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| B-REUSE    | Best     | Item       | An existing workspace implementation of the same pattern can be adapted                                 | Item at class Low                         |
| B-FIXTURE  | Best     | Test batch | A named existing fixture may cover the missing setup of a type B or C batch, but coverage is not verified | Batch one type lower                      |
| B-NOMANUAL | Best     | Allowance  | Automated tests cover every acceptance criterion, and the spec requires no manual validation            | Allowance one size lower; S becomes 0.50 h |
| W-RISK     | Worst    | Item       | A named technical risk affects the item                                                                  | Item at class High                        |
| W-REWORK   | Worst    | Item       | A named risk can invalidate the item's design, such as unverified event timing, rounding, or data shape | Add the class Default once on top of High |
| W-FIXTURE  | Worst    | Test batch | A fixture or setup assumption is not verified                                                            | Add the batch Expected once               |
| W-REVIEW   | Worst    | Allowance  | A remaining risk or decision may change behavior after review or acceptance                             | Add 0.25 h (S), 0.50 h (M), or 1.00 h (L) |
| W-DATA     | Worst    | Allowance  | Representative Business Central data or environment access is assumed rather than verified              | Add 0.50 h                                |
| W-CAUSE    | Worst    | Addition   | A bug cause remains unverified after the triggered analysis level                                       | Use the next level, or add 0.50 h at the highest level |

Apply each condition at most once per line. Do not price the same risk both in a scenario condition and in the fixed-price surcharge.

## Calibration

Read the calibration log through the settings file defined in the [Calibration Log](../../workflow-actuals-record/references/calibration-log.md) contract. A missing settings file, a missing log, or no usable record leaves the estimate uncalibrated. Do not ask for the path during estimation.

A record is usable when `usable` is `true`, `estimate.modelVersion` is `2`, and `actual.activeHours` is greater than zero. Use usable records from the same repository when at least three exist; otherwise use those from all repositories. Consider at most the ten most recent usable records.

Sections 2-4 of the estimate always contain start values. Apply exactly one method per category in section 5, using the first method that applies:

1. **Comparable record**: Use only measurements attributable to the compared scope. For an item, a usable record must contain exactly one item with a near-identical scope and a reported `implementation` actual; replace that item's start value with that actual. For the whole package, a usable record must have a near-identical package scope; multiply every category by that record's category ratio when reported, otherwise by its total ratio. Name the record. Measured comparable work outweighs start values in both directions; justify any value above the measurement.
2. **Category factor**: At least three usable records have a nonzero `estimate.start.{category}` and a reported `actual.breakdown.{category}`. The factor is the median of their `actual.breakdown.{category} / estimate.start.{category}` ratios.
3. **Total factor**: At least three usable records exist. The factor is the median of `actual.activeHours / estimate.start.total`.
4. **Uncalibrated**: Fewer than three usable records exist. The factor is 1.0.

Multiply Best, Expected, and Worst of a category by its factor. Ratios always use the uncalibrated start values stored in each record, so factors never compound. Report the method, factor, usable record count, and log path. If a total factor outside 0.75-1.25 is based on at least five records, state that the start values in this reference require revision.

## Agent runtime

Report agent runtime as an informational range derived from the spec's **Object catalog** (`Object inventory` in specs written before the rename), test batches, and expected build and test cycles. It is never added to an effort total and is not calibrated.

| Work unit                                        | Agent minutes |
| ------------------------------------------------ | ------------: |
| New table or table extension                     |          5-15 |
| Enum or enum extension                           |           2-5 |
| Page or page extension                           |          5-15 |
| Report or report extension                       |         15-45 |
| New business-logic codeunit                      |         15-45 |
| Focused change to an existing object             |          5-20 |
| Interface plus implementation                    |         10-20 |
| Permission set                                   |           2-5 |
| Test batch generation                            |         10-30 |
| Build or test cycle, once per item and per batch |          3-10 |

Token consumption may be reported on the same informational line.

## Quantities

1. **Human effort** equals implementation items plus automated tests plus delivery allowance plus conditional additions. It is the commercial base effort and the headline Best / Expected / Worst range.
2. **Fixed-price total** equals Expected human effort plus a separately displayed 30% risk surcharge, used only when a fixed price is requested and the scope supports it.
3. **Agent runtime** and **waiting time** stay outside both quantities.
