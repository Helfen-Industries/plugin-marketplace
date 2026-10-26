---
name: mcp-al-symbols
description: Use AL Symbols MCP tools reliably for Business Central object, procedure, field, reference, and package searches, and route each question between AL Symbols, BC Observatory, BC Code Atlas, and Microsoft Learn. Always apply before AL symbol queries, when recovering from an empty package index, and before querying Microsoft object facts, base-app procedure bodies, version changes, or localizations.
user-invocable: false
---

# AL Symbols MCP

Use this primitive whenever querying compiled Business Central AL symbols or Microsoft Business Central code and knowledge. Symbol tools search loaded `.app` packages; workspace source is not indexed merely because AL files are present. Apply [Source routing](#source-routing) before choosing a tool.

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

## Source routing

Choose the source by question before querying. BC Observatory and BC Code Atlas are optional; discover their tools before use and fall back to AL Symbols and Microsoft Learn when they are unavailable.

| Question | Source |
|---|---|
| Uncompiled local source changes | Workspace search and read tools |
| Compile-relevant metadata for the project's exact dependency versions, non-Microsoft apps, the own app, and references across loaded packages | AL Symbols MCP, using the process above |
| Microsoft W1, first-party app, or country-layer object facts: IDs, fields, events, obsolete state, changes between versions, localization, documentation pointers | BC Observatory |
| Microsoft procedure bodies and the calls or callers of one procedure | BC Code Atlas |
| Learn page content and AL code samples | Microsoft Learn MCP; prefer a page BC Observatory points to |

- AL Symbols is the single source of truth for what the project compiles against. When another source disagrees, report the version difference and keep the AL Symbols fact.
- BC Observatory covers BC28 and later and contains no procedure bodies or non-Microsoft apps. BC Code Atlas indexes one W1 version, `w1-28` by default; state the queried version when it differs from `application` in `app.json`.
- BC Code Atlas is a remote single-maintainer server. Send only Microsoft object, procedure, or search names, never customer code or identifiers. Use at most two atlas calls per question; never sweep objects, loop over procedures, or request a version build.
- Treat package state as explicit and potentially stale when switching app, test, project, or workspace context. Load and query one owning project at a time.

The workflow is complete only when each answered fact names its source and, for AL Symbols facts, the correct absolute project path was loaded before querying and the loaded package list contains the package expected to own the symbol.
