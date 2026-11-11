---
name: workflow-actuals-record
description: Record the developer's active hours for a delivered Business Central work package, compare them with its estimate per category, write actuals.md beside the spec, and upsert one record in the user-level calibration log that workflow-spec-estimate reads. Use after workflow-pull-request-create creates a PR, or when the user asks to record, add, or correct actual effort for a plan.
argument-hint: <plan folder or canonical spec path> [active hours and optional category split]
user-invocable: true
disable-model-invocation: true
---

# Record Delivery Actuals

Capture measured human effort so future estimates calibrate against delivery rather than start values. Read the [Calibration Log](references/calibration-log.md) contract and use the fixed [Actuals Template](assets/actuals-template.md).

Active time is only what the developer reports. Never derive, propose, or record effort from commit times, branch age, PR creation time, or session duration; developers switch between tasks.

## Input

Require one plan folder `plans/{requirement-source-id-or-NOID}-{short-slug}/` containing `technical-spec.md`. `estimate.md` and a PR reference are optional. The invocation, whether direct or from [Create Pull Request](../workflow-pull-request-create/SKILL.md), authorizes writing `actuals.md` in that plan folder and upserting its record in the configured calibration log. It does not authorize commits, pushes, provider writes, or changes to the spec or estimate.

## Process

1. Resolve the plan folder, delivered spec version, estimate, PR reference, repository identity, and `calibrationLog` from the settings file. Read the repository identity from `.github/copilot/work-package-context.json`, or from the origin remote when the context file has none. Done when every value is known or explicitly `none` and an existing estimate is parsed into its model version, estimated spec version, items, test batches, allowance, Best / Expected / Worst per category, and uncalibrated Expected start values, or into totals only for a v1 estimate.
2. Ask at most one question. Ask for hours only when the invocation supplies none: how many hours the developer actively spent on this package from spec approval to PR, optionally split into implementation items, automated tests, delivery allowance, and conditional additions, and optionally with a short remark. When `calibrationLog` is not configured, include the proposed default path in the same question and ask the developer to confirm it or name another absolute path. Do not ask follow-up questions, suggest an hour value, or distribute a total across categories. Done when a positive total with any supplied split and remark, and the log-path answer when one was asked, are known, or the developer skipped or gave no usable number.
3. If the developer skipped, write nothing and report how to record the time later with `/al-development-workflow:workflow-actuals-record <plan folder> <hours>`. Done when the skip is reported.
4. Compare actuals with the estimate. For each category with an actual, report the deviation from Expected in hours and percent and whether it is below Best, within the range, or above Worst; mark categories without an actual as `not split`. For a v1 estimate, compare only the total; without an estimate, report the actual total alone. Set `usable` to false with the reason when no v2 estimate exists, the estimate does not state its spec version, the delivered spec version differs from the estimated one, or the remark reports material work outside the estimated scope. Done when every row and the usability decision are filled.
5. When the answer confirmed a log path, create or update the settings file with it. When the path was declined or left unanswered, continue without a log. Done when the log path is configured or the record is reported as not stored.
6. Write `actuals.md` from the template, replacing an existing file for the same record key. If `actuals.md` already records a different PR, write `actuals-{PR identifier}.md` instead. Upsert the record as the contract specifies and verify the log. Done when the written file contains every template section and the log check passes, or each write failure is reported.

## Output

Return the actuals path, reported active time, total deviation from Expected, available category deviations, usability with its reason, and calibration log path. End with `Actuals recorded`, `Actuals skipped`, or `Blocked by actuals` with the exact gap. Never change a pull-request result.
