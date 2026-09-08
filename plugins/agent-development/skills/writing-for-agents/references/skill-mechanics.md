# Skill Mechanics

## Identity and discovery

- Use a kebab-case directory and matching frontmatter `name`.
- Make `description` explain both what the skill does and the distinct situations in which it should be loaded.
- Keep trigger synonyms only when they represent how users actually ask for the behavior.

## Roles

- A driver skill owns a user-visible workflow, its order, and its gates.
- A primitive skill contains a reusable discipline another skill can apply.
- A reference skill supplies vocabulary or quality rules and should not pretend to drive a workflow.

Extract a primitive when multiple drivers need the same behavior. Keep a driver thin enough that changing a primitive changes every workflow that consumes it.

## Dependencies

Link dependencies explicitly and state why and when to load them. Do not rely on a skill name alone to communicate its contract. Keep a critical fallback in the driver when failure to load a dependency would make the workflow unsafe.

## Evaluation

Use realistic prompts rather than descriptions of the skill. Include a normal case, a missing-precondition case, and a pressure case that tries to bypass a gate. Expected output should describe observable behavior, not preferred wording.

## Creation checklist

- frontmatter name matches the directory
- description covers output and trigger branches
- side effects and confirmation boundaries are explicit
- every step has a checkable completion condition
- detailed material uses progressive disclosure
- eval prompts distinguish the skill from default behavior
- plugin changelog and human-facing documentation are current
- repository validation passes