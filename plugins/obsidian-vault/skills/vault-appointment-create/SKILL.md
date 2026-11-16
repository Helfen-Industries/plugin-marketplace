---
name: vault-appointment-create
description: Create an appointment in the user's Outlook calendar from a note of the personal Obsidian vault (C:\Dev\Knowledge) or from a direct request - through the vault's Export-Termin.ps1 and the Power Automate flow Vault-Terminexport - with a preview, invitations only after explicit confirmation, a status check of the flow result, and an optional line under ## Termine of the source note. Use when the user says "Termin anlegen", "Termin in Outlook", "Termin aus dieser Notiz", "blockier mir Zeit im Kalender", "lade … zu … ein", or "Terminstatus prüfen".
argument-hint: "<note or topic> <date and time> [end or duration] [location] [attendee e-mails]"
user-invocable: true
---

# Create Outlook Appointment

The new Outlook has no COM and Microsoft Graph needs admin consent, so appointments go through a Power Automate flow: `99-System/Skripte/Export-Termin.ps1` writes a request file to OneDrive, the flow `Vault-Terminexport` creates the event with „Ereignis erstellen (V4)“ and writes the result back. The vault's `AGENTS.md` section „Termine“ defines the rules; `99-System/Skripte/README.md` describes the flow setup and every script parameter.

These rules hold for every branch:

- **Request only:** create an appointment only when the user asks for one. Never change or cancel existing events, create series, or add Teams links; the user does that in Outlook.
- **No invention:** subject, start, and end or duration come from the note or the user. Resolve unambiguous relative dates such as „morgen 9 Uhr“ against today's date and show the absolute date in the preview; ask for vague ones such as „nächste Woche“ or „nachmittags“ and for a missing end or duration. A task's `faellig` is a deadline and its `start`/`ende` is a time block, never the appointment time unless the user says so.
- **Attendees:** only e-mail addresses written in the note or given by the user. A person named without an address is asked for or left out; never derive an address from a name or domain. Attendees receive the invitation immediately, so a request with attendees is sent only after the user explicitly confirmed the preview that lists them.
- **Note link:** pass the source note with `-Notiz`; the script adds the `obsidian://` link to the appointment text only when there are no attendees. Appointment text for attendees contains only what the user confirmed in the preview.

## Process

1. Locate the vault and the script:
   - The vault root is the path the user names, otherwise `C:\Dev\Knowledge`; read its `AGENTS.md` section „Termine“.
   - Check that `99-System/Skripte/Export-Termin.ps1` exists. When it is missing, stop with `Blocked by vault scaffold` and name the missing script.
   - When the user only asks for the status of earlier appointments, continue with step 6.
   - Done when the script exists and the contract has been read.
2. Select the source note when the request refers to one:
   - Find it by path, title, work item ID, or customer or project through the write discipline's resolution, searching the place's notes. Ask when several notes match. A request without a note is allowed and gets no note link and no `## Termine` line.
   - Done when exactly one note or no note is selected.
3. Collect the appointment fields:
   - Subject: the user's wording, otherwise a short subject from the note title with the customer or project name, for example `Assmann: Mapping prüfen`.
   - Start, and end or duration, per the rules above; for an all-day appointment the first and the last day.
   - Optional: location, required and optional attendee addresses, a short text from the user or the note, reminder minutes (default 15, `0` turns it off), and show-as (`busy`, `free`, `tentative`, `oof`, `workingElsewhere`).
   - Ask once for every missing mandatory value in one question. Done when subject, start, and end or duration are known.
4. Preview and confirm:
   - From the vault root run the script with `-WhatIf`, all fields, `-Notiz` for a source note, and `-EinladungenSenden` when there are attendees; `-WhatIf` writes nothing. Fix any reported input error with the user.
   - Show subject, date and time, time zone, location, attendees, text, note link yes or no, and reminder from the script output. With attendees state that Outlook sends the invitations immediately. With a source note also ask whether the `NotizZeile` should be added under `## Termine` afterwards.
   - Done when the user explicitly confirmed this preview; otherwise stop without writing.
5. Create: run the same command without `-WhatIf` and keep the returned `Id`. Done when the status is `übergeben`.
6. Check the result:
   - Run `Export-Termin.ps1 -Status -Id <Id> -WartenSekunden 180`; without a known `Id`, run `-Status`.
   - `angelegt`: take `WebLink` and `NotizZeile`. `fehler`: report the message unchanged and change no note; a new attempt needs a new confirmed request. `offen`: report the `Id`, that the flow can take several minutes, and the `Hinweis`; when no result ever arrived, point to the flow section „Termine: Power-Automate-Flow einrichten“ in `99-System/Skripte/README.md`.
   - Done when every checked request has a status.
7. Add the note line when the user agreed in step 4 and the status is `angelegt`:
   - Apply [Write Vault Note](../vault-note-write/SKILL.md): append `NotizZeile` unchanged under `## Termine` of the source note; when the section is missing, add it at the end of the note. Change nothing else.
   - Done when the write discipline reports `passed` for the note and its commit state, which is `nicht versioniert` for notes.

Run the script with Windows PowerShell from the vault root, for example:

```powershell
powershell -NoProfile -File ".\99-System\Skripte\Export-Termin.ps1" -Betreff 'Assmann: Mapping prüfen' -Beginn '2026-11-20T09:00' -DauerMinuten 60 -Notiz '10-Kunden\Assmann\Aufgaben\2026-11-16 Mapping prüfen.md' -WhatIf
```

## Output

Return the request `Id`, the status (`angelegt`, `offen`, or `fehler` with the message), subject, date and time, whether invitations were sent and to whom, the Outlook link, the source note link with the added line or `keine Notizänderung`, the check result, and the commit state.
