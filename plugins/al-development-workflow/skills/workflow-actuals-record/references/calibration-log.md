# Calibration Log

The calibration log is a JSON Lines file shared across repositories. [Record Delivery Actuals](../SKILL.md) writes it, and `workflow-spec-estimate` reads it as measured comparable data. Keep it outside every customer repository.

## Location

The user-level settings file `~/.copilot/al-development-workflow/settings.json` (`%USERPROFILE%\.copilot\al-development-workflow\settings.json` on Windows) names the log with an absolute path:

```json
{
  "version": 1,
  "calibrationLog": "D:/Estimation/estimation-calibration.jsonl"
}
```

Ignore unknown properties. When proposing a missing setting, offer `~/.copilot/al-development-workflow/estimation-calibration.jsonl` expanded to an absolute path, and accept any absolute path the developer names. Create missing parent directories and the log on the first write. Never store credentials, requirement text, or customer prose; `scope` values are short technical summaries.

## Record

Each line contains one compact UTF-8 JSON object:

```json
{"schema":1,"key":"contoso/service-app|4711-service-release|https://github.com/contoso/service-app/pull/42","recordedAt":"2026-11-11T17:30:00+01:00","repository":"contoso/service-app","plan":"4711-service-release","pullRequest":"https://github.com/contoso/service-app/pull/42","requirementType":"Change request","specVersion":"2","estimate":{"modelVersion":2,"specVersion":"2","allowance":"M","items":[{"id":"1","class":"Small","scope":"Release status field on Service Header and page"},{"id":"2","class":"Medium","scope":"Release check before posting"}],"testBatches":[{"id":"T1","type":"A","scenarios":6}],"start":{"implementation":1.4,"tests":0.25,"allowance":1.5,"additions":0,"total":3.15},"best":{"implementation":1.25,"tests":0.25,"allowance":1.5,"additions":0,"total":3.0},"expected":{"implementation":1.4,"tests":0.25,"allowance":1.5,"additions":0,"total":3.25},"worst":{"implementation":1.9,"tests":0.5,"allowance":2.0,"additions":0,"total":4.5}},"actual":{"activeHours":2.5,"breakdown":{"implementation":null,"tests":null,"allowance":null,"additions":null}},"usable":true,"notUsableReason":null,"remark":null}
```

| Field                                 | Meaning                                                                                              |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `schema`                              | Record format version, currently `1`                                                                 |
| `key`                                 | `{repository}\|{plan}\|{pull request URL or manual}`; unique in the log                              |
| `recordedAt`                          | ISO 8601 timestamp with offset                                                                       |
| `repository`                          | `owner/repository` for GitHub or `organization/project/repository` for Azure Repos                   |
| `plan`                                | Plan folder name                                                                                     |
| `pullRequest`                         | PR URL or `null`                                                                                     |
| `requirementType`                     | `User story`, `Bug`, or `Change request`                                                             |
| `specVersion`                         | Spec version that was delivered                                                                      |
| `estimate`                            | `null` when no estimate exists                                                                       |
| `estimate.modelVersion`               | `2` for the current model; `1` for estimates with the former eleven fixed rows                       |
| `estimate.specVersion`                | Spec version that was estimated                                                                      |
| `estimate.allowance`                  | `S`, `M`, `L`, or `null`                                                                             |
| `estimate.items`                      | `{id, class, scope}` for each implementation item                                                    |
| `estimate.testBatches`                | `{id, type, scenarios}` for each test batch                                                          |
| `estimate.start`                      | Uncalibrated, unrounded Expected start values per category and total                                 |
| `estimate.best`, `.expected`, `.worst` | Published calibrated values per category; totals rounded as published                               |
| `actual.activeHours`                  | Total active hours reported by the developer                                                         |
| `actual.breakdown`                    | Reported hours for `implementation`, `tests`, `allowance`, and `additions`; `null` when not reported |
| `usable`                              | Whether the record may calibrate future estimates                                                    |
| `notUsableReason`                     | Reason when `usable` is `false`, otherwise `null`                                                    |
| `remark`                              | Short developer remark or `null`                                                                     |

Use numbers with up to two decimals. For a v1 estimate, set `estimate.items`, `estimate.testBatches`, `estimate.allowance`, and every category value to empty or `null`, and keep only the totals. Estimation uses v2 records only.

Record only the categories the developer named; the others stay `null`. When the named categories sum to more than `actual.activeHours`, or all four are named and their sum differs from it by more than 0.05 h, keep the total, set every breakdown value to `null`, and state the mismatch in `remark`.

## Writing

Upsert by `key`: replace the existing line with the same key or append one line. Preserve every other line unchanged. After writing, verify that every line parses as JSON and that exactly one line contains this key.
