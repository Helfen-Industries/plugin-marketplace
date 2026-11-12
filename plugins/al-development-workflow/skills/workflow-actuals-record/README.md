# Record Delivery Actuals

Feedback loop for `workflow-spec-estimate`: records the developer's reported active hours after delivery and compares them with the estimate.

```text
/al-development-workflow:workflow-actuals-record <plan folder or canonical spec path> [active hours and optional category split]
```

`workflow-pull-request-create` runs it after a PR is created and asks one skippable question about active time. Run it directly to record or correct the time later. Commit, branch, and PR timestamps are never treated as effort.

It writes `actuals.md` beside the spec and upserts one JSON Lines record in the user-level calibration log named by `calibrationLog` in `~/.copilot/al-development-workflow/settings.json`. Future estimates use usable records from that log to calibrate their start values.
