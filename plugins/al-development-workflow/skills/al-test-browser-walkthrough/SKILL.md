---
name: al-test-browser-walkthrough
description: Play a documented Business Central test scenario through the signed-in web client in the integrated browser, compare each observed result with its expected outcome, and save screenshots as files. Use for manual validation of acceptance criteria that automated tests cannot cover, for screenshots of delivered behavior, and for web client sign-in, session, or error-dialog problems during such a walkthrough.
user-invocable: false
---

# Walk Through The BC Web Client

Own browser interaction with a Business Central web client that the user has signed in. Execute only the scenario's steps on the named test container, never on production.

## Input

Require ordered steps with an expected result each (scenario document or plan), the web client URL and company, and the screenshot destination. When the caller names no destination, use a temporary folder outside the repository working tree. Read [Web Client Notes](references/web-client-notes.md) before the first browser action.

## Process

1. Locate the shared browser tab and confirm it shows the BC client for the named company on a test container. On a sign-in page, ask the user once to sign in, never enter credentials, and re-check that the page left the sign-in state. When the question returns without a real answer, end the turn with a blocker message: completed steps, the exact user action, and the sentence to continue. Done when the client shell is visible for the named company.
2. Plan every screenshot before navigating: one numbered file name per step that needs a picture, such as `01-actions-plan.png`. Done when each screenshot has a name and a source step.
3. Execute each step and read its result as text (snapshot, title, URL, or page evaluation). Record observed against expected per step; a statement such as "missing" or "not published" needs a snapshot read and, for list rows, a screenshot check. Done when every step has an observed result.
4. Save each planned screenshot straight to its file with Playwright `page.screenshot({path, clip})` in the same call as the final action, after closing tour popups and hint banners and moving the mouse away. Done when every planned file exists and shows only the intended area, without tooltips, banners, personal data, or unrelated records.
5. On any deviation, decide whether code, test data, or the expectation is wrong before changing anything. For a code defect, return to [Run AL Tests TDD](../al-test-run-tdd/SKILL.md) and add a test that would have caught it. Done when each deviation has a classified cause and an owner.
6. Revert everything changed only for the walkthrough, such as assigned permission sets and setup values, and delete temporary files. Done when the container state matches the start apart from the scenario's own records.

## Output

Report per step: expected, observed, screenshot file. List deviations with their classified cause and what was reverted or cleaned up. End with `Walkthrough complete` only when every step has an observed result and every planned screenshot exists.
