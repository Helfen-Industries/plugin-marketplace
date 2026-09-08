---
name: workflow-decisions-grill
description: Grill the user about implementation decisions until every reachable branch is resolved and shared understanding is confirmed. Use when requirements, behavior, interfaces, compatibility, or acceptance criteria still depend on human decisions.
user-invocable: true
---

# Grilling

## Input

Require a subject, known facts, and the decisions already identified. Keep pending facts separate from user-owned decisions.

## Process

1. Build a decision tree for the subject. Every decision may reveal dependent decisions; do not flatten the tree into one undifferentiated questionnaire. Done when every known decision has prerequisites, consequences, and valid options, or is marked as a pending fact.
2. Ask the current frontier using the round format below, then wait for the user's answers. Done when each answer is recorded verbatim enough to preserve constraints and the frontier has been recomputed.
3. Repeat until the frontier is empty. Summarize the resolved decisions and implementation consequences, then ask the user to confirm the shared understanding. Done only when that confirmation is explicit.

## Rounds

The frontier is every unresolved decision whose prerequisites are already settled. Ask the whole frontier in one round, then wait for the user's answers before recomputing it.

Format each question as:

```text
Q1 - <short title>
<decision, consequence, and genuinely valid options>

Recommended: <one recommendation with brief reasoning>
```

Questions that depend on an answer in the current round belong to a later round. Keep question count as high as needed, but keep round count low.

## Facts and decisions

Finding facts is the agent's job. Read the workspace, source item, configuration, or available read-only tools instead of asking the user for discoverable information. A pending fact blocks only decisions that depend on it; continue with the rest of the frontier.

Decisions belong to the user. A recommendation is not an answer. Treat skipped, empty, unavailable, or uncertain answers as unresolved unless the user explicitly decides to defer the question and accepts the consequence.

## Completion gate

The interview is complete only when the frontier is empty and the user explicitly confirms the summarized understanding. Do not plan, implement, write files, or act on the decisions before that confirmation. Otherwise return the current frontier and `Blocked by clarification`.