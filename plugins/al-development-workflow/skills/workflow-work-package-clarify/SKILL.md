---
name: workflow-work-package-clarify
description: Turn unresolved implementation decisions in an AL work package into a small set of precise questions and prevent planning from proceeding on invented defaults. Use after requirements and code exploration expose ambiguity or missing decisions.
user-invocable: false
---

# Clarify Work Package

Apply [Grilling](../workflow-decisions-grill/SKILL.md) to the implementation decisions exposed by requirements analysis and code exploration.

## Input

Require completed analysis and exploration handoffs. If a supposed decision can still be resolved from an identified evidence source, return it to exploration instead of asking the user.

## Process

1. Seed the decision tree from open decisions, contradictions, risks, and requirement-versus-code conflicts already found. Include only decisions that affect behavior, data, interfaces, compatibility, security, performance, upgrade behavior, testing, or acceptance. Done when each seed is either a user-owned decision or routed to an evidence source.
2. Apply [Grilling](../workflow-decisions-grill/SKILL.md). Preserve exact numeric defaults, ordering guarantees, negative requirements, and rejected alternatives as decisions settle. Done when the decision ledger reflects every answer and newly reachable branch.
3. Keep the workflow blocked until the grilling completion gate is satisfied. Done when no decision is open and the user explicitly confirms the summarized understanding.

## Output

Maintain a decision ledger with `Resolved decisions` and `Open decisions`. For each resolved decision, record the user's answer and its implementation consequence. End with `Blocked by clarification` while any answer or shared-understanding confirmation is missing; otherwise return the confirmed ledger for planning.