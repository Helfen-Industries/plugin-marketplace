---
name: mcp-al-symbols
description: Use AL Symbols MCP tools reliably for Business Central object, procedure, field, reference, and package searches. Always apply before AL symbol queries and when recovering from an empty package index.
user-invocable: false
---

# AL Symbols MCP

Use this primitive whenever querying compiled Business Central AL symbols. Symbol tools search loaded `.app` packages; workspace source is not indexed merely because AL files are present.

## Process

1. Identify the owning AL project by locating the relevant `app.json` and `.alpackages`. In multi-project workspaces, use the project that owns the active or referenced AL file; ask only when multiple plausible owners remain. Done when one absolute project-folder path is established.
2. Make the package tool and required symbol operation available through tool discovery when they are deferred. Do not call a deferred AL MCP tool before discovery. Done when `mcp_al-mcp-server_al_packages` and the required query tool are available.
3. Load packages synchronously before the first symbol query with `action: load`, the absolute project-folder `path`, `autoDiscover: true`, and `forceReload: false`. Never parallelize loading with symbol queries. Done when loading completes and reports relevant packages.
4. If the load result is unclear, verify package state with `action: list`; use `action: stats` when object-index confirmation is useful. Done when at least one package expected to own the requested symbol is loaded.
5. Run the narrowest required symbol query. Prefer summary mode and package, object, or member filters; request a full definition only when a summary cannot answer the question. Done when the result comes from the verified package state and answers the requested symbol question or establishes that the symbol is absent.

## Empty-index recovery

When a symbol query returns `No AL packages loaded from YOUR WORKSPACE`:

1. Stop issuing symbol queries.
2. Confirm the selected folder contains `app.json` and normally `.alpackages`.
3. Reload synchronously with `forceReload: true`.
4. Verify with `action: list` or `action: stats`.
5. Retry the original query once.

If no packages load, check for `.app` symbol files and use the available AL symbol-download workflow when dependencies are missing. Report concrete parsing or compatibility errors without replacing them with guesses.

## Boundaries

- Treat package state as explicit and potentially stale when switching app, test, project, or workspace context. Load and query one owning project at a time.
- Use AL Symbols MCP for compiled object metadata and references.
- Use workspace search and read tools for uncompiled local source changes.
- Use Microsoft Learn tools for documentation and code examples.

The workflow is complete only when the correct absolute project path was loaded before querying and the loaded package list contains the package expected to own the symbol.
