# AL Review Gate

Review the whole implementation, not only style or the last edited file.

## Finding threshold

A finding must identify a concrete defect, regression risk, contract mismatch, maintainability hazard, or missing proof. Do not report generic preferences. Order findings by severity:

- **Critical**: data loss, security exposure, destructive upgrade, or release-blocking corruption.
- **High**: incorrect business behavior, broken integration, missing required permission, or likely production failure.
- **Medium**: credible edge-case defect, unsupported upgrade path, meaningful performance issue, missing required test, or maintainability problem likely to cause defects.
- **Low**: bounded quality issue worth fixing but not release-blocking.

Each finding includes file and symbol, consequence, evidence, mapped requirement or convention, and smallest valid correction.

## Review dimensions

- canonical-spec coverage, exclusions, and approved deviations
- AL correctness, validation triggers, transactional behavior, locking, and error handling
- event selection, subscriber behavior, extensibility, and dependency compatibility
- SQL behavior, filtering, keys, FlowFields, SetLoadFields, loops, and data volume
- permissions, entitlements, data classification, secrets, and sensitive logging
- install, upgrade, migration, backward compatibility, and existing data
- captions, labels, tooltips, translations, accessibility, and user-visible errors
- API and integration contracts, retries, idempotency, and failure behavior
- scenario-to-test traceability, assertion quality, fixture isolation, manual-test justification, and Test Results evidence
- dead code, duplication, unnecessary abstraction, generated noise, debug artifacts, and unrelated churn
- customer documentation accuracy for setup, permissions, migration, and limitations

Absence of a finding means the dimension was checked, not assumed.