---
name: vault-meeting-note
description: Turn raw meeting notes, bullet points, or a transcript into a structured meeting note in the Meetings folder of a customer or internal project in the Obsidian vault, with decisions, open questions, and todos in vault syntax, then propose ADRs for lasting decisions, fact-sheet updates, and answers to known open questions. Use when the user says "Meeting-Notiz ablegen" or "Protokoll", pastes notes from a customer or project meeting, workshop, or call, or asks to document what was discussed or agreed.
argument-hint: "<customer or project> <date> <title> and the raw notes"
user-invocable: true
---

# Record Meeting Note

Apply [Write Vault Note](../vault-note-write/SKILL.md) for every file change.

## Process

1. Establish customer or project, Teilprojekt, meeting date, and title from the input; the date may appear in the notes. Set `teilprojekt` only when the input or the customer's Teilprojekte (from the context brief) name one; a meeting about several lists them all. When the date is missing, ask once, unless the user states the meeting was today. Derive a short title from the agenda when none is given. Take participants only from the input. Done when customer or project, date, and title are known.
2. Apply [Load Customer Context](../vault-customer-context/SKILL.md) for the customer or project, with the work item when the notes mention one. Done when the brief is available or `Kein Kundenkontext` is reported, in which case the note goes to `00-Inbox/` per the write discipline.
3. Place every input statement in exactly one template section, or drop it as small talk or duplicate:
   - **Entscheidungen** only when the input states that something was decided or agreed; otherwise the statement is an open question.
   - **Todos** as `- [ ] Aufgabe` for the user's own tasks and `- [ ] @Name: Aufgabe` for others; due dates `📅 YYYY-MM-DD` only when stated; work items as `AB#<id>` and in `devops`. A todo with its own content, such as a work package, becomes a follow-up task note instead.
   - Never invent owners, dates, numbers, or decisions.
   - Done when every substantive statement is placed exactly once.
4. Write the note from `90-Templates/Meeting.md` through the write discipline, linking concepts and ADRs from the brief that the meeting touched. Done when the write discipline reports `passed`.
5. Present the follow-ups as one list and apply only confirmed items:
   - each lasting decision: [Record Decision](../vault-decision-record/SKILL.md), then link the ADR under `## Entscheidungen`;
   - each new verifiable fact: [Update Customer Profile](../vault-profile-update/SKILL.md) with source `Meeting YYYY-MM-DD`;
   - each own task with its own content: [Create Task](../vault-task-create/SKILL.md) with `quelle: meeting`;
   - each answered open question from the brief: check it off where it lives as `- [x] <Frage> – <Antwort> (Meeting YYYY-MM-DD) ✅ YYYY-MM-DD`.
   - Done when every proposal is applied, declined, or recorded as a todo in the meeting note.

## Output

Return the note link, the number of decisions, open questions, and todos (own and delegated), the state of each follow-up, and the commit and push state.
