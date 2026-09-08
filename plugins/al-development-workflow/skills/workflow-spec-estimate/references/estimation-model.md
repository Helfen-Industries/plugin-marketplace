# Estimation Model

Estimate for an AI-assisted AL developer working from a ready canonical spec. Prefer measured active duration from comparable completed work; use these ranges only when better local evidence is unavailable.

## Classification

Classify the requirement source as `User story`, `Bug`, or `Change request`. An assigned Task remains the entry reference and may contribute implementation constraints, but its type and description do not replace the parent User Story classification or requirements. Then classify each acceptance-criterion or implementation-plan item. Group items only when they share the same objects, implementation routine, and validation cycle.

| Class   | Typical scope                                                        | Expected development effort |
| ------- | -------------------------------------------------------------------- | --------------------------: |
| Trivial | Caption, visibility, filter, or similarly local declarative change   |                  0.25-0.5 h |
| Small   | One field across table/page, one subscriber, or focused local logic  |                   0.5-1.0 h |
| Medium  | New calculation, report, or coordinated change across objects        |                   1.5-3.0 h |
| Large   | New process, posting logic, journal flow, migration, or upgrade code |                   4.0-8.0 h |

Classification expresses delivery complexity, not object count. A related object batch may be one item; unrelated acceptance criteria remain separate.

## Calibration ranges

| Work unit                      | Reference minutes | Main variance                  |
| ------------------------------ | ----------------: | ------------------------------ |
| New table                      |              5-15 | fields, keys, SIFT, FlowFields |
| Table extension                |              5-10 | fields and validation          |
| Enum / enum extension          |               2-5 | values and compatibility       |
| Page or page extension         |              5-15 | layout and interaction         |
| Report with simple layout      |             20-45 | dataset and layout design      |
| Business-logic codeunit        |             15-45 | algorithm and edge cases       |
| Focused existing-object change |              5-20 | discovery and wiring           |
| Interface plus implementation  |             10-20 | dispatch complexity            |
| Permission set                 |               2-5 | breadth of grants              |
| First test batch and fixture   |              5-15 | environment setup              |
| Additional similar scenario    |               1-3 | shared fixture reuse           |

Complexity and validation cycles matter more than object count. Generate related objects and scenarios as batches where one coherent edit and test run can cover them.

Use object ranges to cross-check classified development effort, not as additional hours. Explain material disagreement between the two views.

## Activity calibration

### Consultant and product alignment

| Situation                                              | Expected effort |
| ------------------------------------------------------ | --------------: |
| Complete requirements and acceptance criteria          |           0.5 h |
| One or two expected functional questions               |           1.0 h |
| Unclear behavior or likely acceptance feedback         |           1.5 h |
| Additional owner coordination for a shared application |          +0.5 h |

### Analysis and reproduction

Use this category primarily for bugs or an unverified cause.

| Situation                                                | Expected effort |
| -------------------------------------------------------- | --------------: |
| Cause supported directly by current code evidence        |             0 h |
| Reproduction required with source available              |           1.0 h |
| Reproduction required with dependency symbols only       |           2.0 h |
| Posting flow or representative data analysis is required |           2.5 h |

### Dependent applications

| Situation                                           | Expected effort |
| --------------------------------------------------- | --------------: |
| No dependent application change                     |             0 h |
| Owned app event, version, and release change        |           1.0 h |
| Owned shared-app behavior affecting other consumers |           2.0 h |
| Third-party request and temporary workaround        |           3.0 h |

External release lead time is waiting time, not effort.

### Automated tests

| Situation                                    |             Expected effort |
| -------------------------------------------- | --------------------------: |
| Existing fixture for the business area       |              0.5 h per case |
| Missing fixture                              | 2.0 h once + 0.5 h per case |
| Posting run required in automated validation |                      +1.0 h |

Count shared fixture setup once and identify it as reusable.

### Manual validation

| Situation                                | Expected effort |
| ---------------------------------------- | --------------: |
| One scenario without posting             |           0.5 h |
| Two to four scenarios                    |           1.5 h |
| Multiple document types or posting paths |           2.5 h |
| Each additional company or language      |          +0.5 h |

### Documentation and delivery

| Activity                                 | Expected effort |
| ---------------------------------------- | --------------: |
| Test evidence with up to 5 screenshots   |           0.5 h |
| Test evidence with 6-12 screenshots      |           1.0 h |
| More screenshots or process variants     |           1.5 h |
| Build with no new translatable text      |           0.5 h |
| Build plus captions, tooltips, or labels |           1.0 h |
| Second repository and PR cycle           |          +0.5 h |

Estimate solution documentation separately from test evidence. Use `0 h` when the spec requires no deliverable beyond code and test evidence.

## Scenario ranges

Estimate each fixed category for three scenarios:

- **Best**: named favorable conditions hold, expected reuse works, and validation passes first time.
- **Expected**: most likely delivery path using verified evidence and ordinary direct corrections.
- **Worst**: named technical risks materialize without adding unrequested scope.

Derive scenario values from concrete conditions. When no better evidence exists, use `Best = Expected x 0.75` and `Worst = Expected x 1.30`, rounded to the nearest `0.25 h`, then explain the conditions represented by that spread. A zero Expected value remains zero in all scenarios unless a named risk activates the category.

Potential sensitivity signals include dependency symbols without source, shared-app impact, unknown defect cause, posting or valuation logic, multiple companies or localizations, migration, missing representative test data, reusable comparable logic, an existing publisher, an existing test fixture, and purely additive behavior. Do not apply percentage modifiers mechanically when the scenario rows already price the same risk.

## Quantities

1. **Active implementation time**: analysis and reproduction, development, dependent-app changes, automated tests, build and translations, and expected direct corrections.
2. **Commercial base effort**: all hour-valued rows, including alignment, manual validation, review, and documentation that will actually occur.
3. **Fixed-price total**: Expected commercial base plus a separately displayed 30% risk surcharge when fixed price is requested and the scope supports it.

Token consumption is informational and never converted to hours. Waiting time is reported separately and never included in effort totals. Do not count the same uncertainty in scenario spread, expected bug fixing, and the fixed-price surcharge.

## Fixed rows

Keep these rows in this order: Consultant / product alignment, Analysis and reproduction, Development, Dependent application changes, Automated tests, Manual validation, Test documentation, Build and translations, Code review and PR, Expected bug fixing, Solution documentation.

Use `0 h` with a reason when a category does not apply. State every assumption and justify deviations above the calibration ranges. A ready spec with ordinary focused AL work usually needs `0-0.25 h` Expected direct bug fixing unless concrete integration, migration, environment, or algorithmic risk supports more.
