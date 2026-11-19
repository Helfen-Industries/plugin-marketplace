# Web Client Notes

Tool names differ by host; use the capability. Snapshot: `read_page` / `readPage`. Click by element reference: `click_element` / `clickElement`. Playwright code: `run_playwright_code` / `runPlaywrightCode`. Screenshot for viewing: `screenshot_page` / `screenshotPage`. Dialogs: `handle_dialog` / `handleDialog`.

## Tool behavior

- A snapshot omits the values of the selected list row; they exist only in text boxes, so read the screenshot before concluding a value is missing. Large snapshots land in a file: search it for `ref=`, `menuitem`, and `dialog`.
- A click needs a reference from the current snapshot. References change after every dialog or page change; on "element was detached" read the page again. Selectors such as `role=` mostly fail inside the client frame, so use the reference.
- The screenshot tool returns an image for viewing, not a file, and may lag behind the state.
- Playwright code is reliable for files and frames: `page.screenshot({path, clip})`, `page.frameLocator('iframe').first()`, `page.getByRole(...)`, `page.mouse`, `page.evaluate`. A long run returns a deferred result identifier; continue it with that identifier.
- Use the dialog tool only for real browser dialogs. A `beforeunload` during navigation often has no active dialog: navigation continues, so read the page again.

## Navigation

- URL: `https://<server>/<instance>/?company=<company>&tenant=default&page=<id>`. Page 2500 is Extension Management.
- List filter by AL names: `&filter='<Table Name>'.'<Field Name>' IS '<value>'`. Other filter forms fail with HTTP 400. Stored `bookmark=` URLs work only while the app version and session are unchanged.
- Going back reloads the list when it goes too far, which invalidates all references.
- Sub-menu references appear in the snapshot only after the parent menu is clicked.

## Image budget

Hosts abort a chat after too many screenshots shown to the model.

1. Verify a click with text: the snapshot returned by Playwright code, `page.title()`, `page.url()`, or `page.evaluate`. Combine click, wait, and text check in one call.
2. View a saved file once, only when its content is uncertain, and never again after it is accepted.
3. Keep the list of finished files. After an interruption, list the screenshot folder and resume at the first missing file instead of replaying the scenario.
4. Do not call `page.setViewportSize`: the client lays out only on load, so later shots are cut off. Plan sections with `clip`.
5. After `page.goto` the client shows "Getting ready..." for several seconds. Click only after a rendered control is found, for example `await page.getByRole('menuitem', {name: '<action>'}).first().waitFor()`. Early coordinate clicks hit other controls; if an analysis-mode tab appears, reload without it.
6. Prefer role locators over coordinates. When a locator times out, read the snapshot text instead of taking a picture.
7. For a wide grid, take the left part, scroll with `page.mouse.wheel(400, 0)` in a separate call, then take the right part. Better: ask for the needed columns to come first in the page layout.
8. Repeated warning dialogs may not be found by text; click OK by coordinate in a loop of fixed length, then check the page by text.

## Dialogs and errors

- On an error dialog, open "Share details" (German: "Details teilen"), read the call stack, then close it.
- Answer Yes/No confirmations only when the consequence is clear. Answer No to prompts that update the field for all records.
- "An administrator has changed one or more extensions": close with OK and reload. After a publish the session is gone, so ask the user to sign in again.
- Before a screenshot, maximize wide pages so columns are visible, and crop header, lines, and action bar separately when one image would be unreadable.
