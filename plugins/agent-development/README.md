# Agent Development

Reusable workflows and writing guidance for creating reliable GitHub Copilot agent skills and other agent-facing instructions.

## Get Started

Register the marketplace and install the plugin:

```powershell
copilot plugin marketplace add Helfen-Industries/plugin-marketplace
copilot plugin install agent-development@helfen-agent-marketplace
copilot plugin list
```

Create or substantially revise a skill:

```text
/agent-development:create-agent-skill <intended behavior and target plugin or repository>
```

Describe the behavior the skill should enable, representative triggering requests, expected output, required tools, side effects, and any confirmation gates. The workflow inspects local conventions before choosing the skill architecture.

## Contents

| Skill                | Role              | Purpose                                                                                        |
| -------------------- | ----------------- | ---------------------------------------------------------------------------------------------- |
| `create-agent-skill` | Public driver     | Designs or revises a skill, references, assets, evals, documentation, and validation           |
| `writing-for-agents` | Hidden discipline | Makes agent-facing documents discoverable, actionable, testable, and free of behavioral no-ops |

`create-agent-skill` uses the writing discipline and its skill-mechanics reference automatically. The hidden skill can also guide agents when they edit instructions, prompts, workflow references, or similar agent-consumed documents.

## Usage

### Create A Skill

```text
/agent-development:create-agent-skill Create a release-notes skill for our plugin repository. It should trigger from release preparation requests, derive notes from the current changelog and diff, ask before writing, and include evals.
```

The workflow will:

1. establish triggers, outputs, tools, side effects, and completion criteria;
2. inspect neighboring skills and repository validation rules;
3. choose a driver, primitive, reference, script, or asset structure only where needed;
4. create discovery metadata and checkable workflow steps;
5. add normal, missing-precondition, and gate-bypass eval cases;
6. update documentation and changelog entries and run validation.

### Revise An Existing Skill

Provide the existing skill path and the behavior that is missing or unreliable:

```text
/agent-development:create-agent-skill Revise plugins/example/skills/create-release so it refuses releases with an unvalidated manifest and reports a stable blocked state.
```

The workflow preserves established repository conventions and avoids unrelated abstractions or rewrites.

### Expected Skill Quality

- The folder and frontmatter `name` use matching kebab-case identifiers.
- The description contains real discovery triggers.
- Every operative step has a checkable completion condition.
- Dependencies and context pointers state when and why they are loaded.
- Side effects and confirmation boundaries are explicit.
- Evals cover normal use, missing preconditions, and pressure to bypass a gate.
- Plugin documentation, changelog, and repository validation remain current.

See [CHANGELOG.md](CHANGELOG.md) for release history.