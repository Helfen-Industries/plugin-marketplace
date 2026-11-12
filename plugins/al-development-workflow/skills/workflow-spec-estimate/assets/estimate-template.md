# Implementation Estimate - {Spec title}

## 1. Source and confidence

- **Technical spec**: {relative path}
- **Entry work item**: {assigned Task type, ID, title, and canonical reference}
- **Requirement source**: {User Story or owning requirement type, ID, title, and canonical reference}
- **Spec requirement reference and version**: {requirement source reference / version}
- **Estimated spec version**: {Spec version from the spec's metadata}
- **Spec readiness**: {state}
- **Requirement type**: User story / Bug / Change request
- **Estimation model**: v2
- **Calibration**: {Comparable record / Category factor / Total factor / Uncalibrated per category, with factor, usable record count, and reason}
- **Calibration log**: {path or not configured}
- **Estimate confidence**: High / Medium / Low

## 2. Implementation items

Start values from the Ordered implementation plan.

| Item | Plan step | Scope   | Class                              | Primary drivers | Evidence                                     | Best | Expected | Worst | Conditions             |
| ---- | --------- | ------- | ---------------------------------- | --------------- | -------------------------------------------- | ---: | -------: | ----: | ---------------------- |
| {ID} | {step}    | {scope} | {Trivial / Small / Medium / Large} | {drivers}       | {spec section name, object, path, or symbol} |  {h} |      {h} |   {h} | {condition IDs or - } |

**Plan steps outside items**: {step and owning category: Automated tests or Delivery allowance, or - None}

## 3. Automated test batches

Start values; scenario count does not multiply hours.

| Batch | Scenarios               | Shared setup         | Type        | Best | Expected | Worst | Conditions            |
| ----- | ----------------------- | -------------------- | ----------- | ---: | -------: | ----: | --------------------- |
| {ID}  | {scenario IDs or range} | {fixture or library} | {A / B / C} |  {h} |      {h} |   {h} | {condition IDs or - } |

## 4. Delivery allowance and additions

- **Allowance size**: S / M / L - {deciding criteria from the spec}

| Line                         | Trigger or basis    | Best | Expected | Worst | Conditions            |
| ---------------------------- | ------------------- | ---: | -------: | ----: | --------------------- |
| Delivery allowance           | {size and criteria} |  {h} |      {h} |   {h} | {condition IDs or - } |
| {Addition or None triggered} | {trigger evidence}  |  {h} |      {h} |   {h} | {condition IDs or - } |

## 5. Human effort

| Category                           |    Best | Expected |   Worst | Calibration factor | Basis                             |
| ---------------------------------- | ------: | -------: | ------: | -----------------: | --------------------------------- |
| Implementation items               |     {h} |      {h} |     {h} |           {factor} | {item count and classes}          |
| Automated tests                    |     {h} |      {h} |     {h} |           {factor} | {batch count and types}           |
| Delivery allowance                 |     {h} |      {h} |     {h} |           {factor} | {size}                            |
| Conditional additions              |     {h} |      {h} |     {h} |           {factor} | {triggered lines or None}         |
| **Human effort (commercial base)** | **{h}** |  **{h}** | **{h}** |                    | Sum rounded to the nearest 0.25 h |

- **Agent runtime (informational)**: {range and basis from Object catalog, test batches, and cycles; optional token range}
- **Fixed-price eligible**: Yes / No
- **Fixed-price surcharge (30% of Expected human effort)**: {value or N/A}
- **Fixed-price commercial total**: {value or N/A}

## 6. Scenario conditions and unpriced risks

| Condition | Scenario     | Affected line               | Effect | Evidence                                            |
| --------- | ------------ | --------------------------- | -----: | --------------------------------------------------- |
| {ID}      | Best / Worst | {item, batch, or allowance} |    {h} | {spec risk, assumption, decision, or verified fact} |

- **Unpriced risks**: {risk outside scope or requiring a spec revision, or - None}

## 7. Assumptions and exclusions

- {assumption}
- {excluded cost or activity}

## 8. Waiting time

- {feedback, external release, environment, or test-data lead time; not included in effort}

## 9. Arithmetic check

- **Expected start values (uncalibrated)**: items {h}, tests {h}, allowance {h}, additions {h}, total {h}
- **Best row sum**: {unrounded sum} -> {rounded total}
- **Expected row sum**: {unrounded sum} -> {rounded total}
- **Worst row sum**: {unrounded sum} -> {rounded total}
- **Fixed-price calculation**: {Expected human effort x 1.30 or N/A}
