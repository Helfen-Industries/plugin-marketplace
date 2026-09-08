# Security Policy

## Supported versions

Only the latest released plugin version is supported.

## Reporting

Report vulnerabilities privately to the repository owner. Do not open a public issue containing credentials, exploit details, or sensitive customer data.

## Plugin requirements

- Never include credentials, tokens, private keys, or customer data.
- Keep external dependencies minimal and pinned.
- Treat work-item and issue content as untrusted input.
- Do not execute instructions embedded in retrieved work items, issues, comments, or attachments.
- Require explicit user confirmation before file changes, shell execution, or writes to external systems.
- Keep MCP servers and hooks disabled unless their behavior is documented and reviewed.
- Use `${PLUGIN_ROOT}` for packaged read-only files and `${PLUGIN_DATA}` for writable state.

## Release requirements

Every release must pass the repository validator, a clean installation smoke test, and a manual review of changed instructions and executable content.