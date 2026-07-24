# LiveStack Events QA Guide

## Purpose

LiveStack Events let WMS users request one parent event code for a LiveStack while still using regular workshop event codes for each selected LiveStack entry.

This gives event teams one public LiveStack event link, but each workshop inside the LiveStack can still behave like a normal LiveLabs event code with its own workshop-specific event record.

## Main Objects

There are three related concepts:

- **LiveStack**: The existing collection of entries. Each entry points to a workshop, sandbox, tenancy, or other LiveStack content.
- **LiveStack Event**: The parent event code for the whole LiveStack. This can override the LiveStack title, description, outline, prerequisites, date range, timezone, and user limits.
- **Workshop Event Codes**: Regular event codes for the selected workshop entries inside the LiveStack Event. These are the same event-code objects used by normal workshop events.

The parent LiveStack Event does not replace the workshop events. It owns the LiveStack-level event page and maps selected entries to their workshop event codes.

## Application Areas

### WMS

WMS is where users request and manage LiveStack Events.

Relevant pages:

- **Page 44: Manage All My Events**
  - Now includes both regular workshop events and LiveStack Events.
  - Users can start event creation from the combined event request flow.

- **Page 69: Request an Event Code**
  - Entry page for choosing which type of event to create.
  - Workshop Event is the default path for a normal single-workshop event.
  - LiveStack Event is for LiveStacks only.

- **Page 70: LiveStack Event Details**
  - Main request/edit page for LiveStack Events.
  - Users choose the LiveStack, event metadata, date range, timezone, user limits, and optional content overrides.
  - Users choose which LiveStack entries should receive workshop event codes.
  - After first save, selected entries get generated workshop event rows.
  - Generated workshop event rows can be opened from the associated entries table and edited on the regular event form.

### LiveLabs Admin

LiveLabs Admin is where LiveStack Events can be reviewed or managed after they exist in LiveLabs.

Relevant pages:

- **Page 9166: LiveStack Event Codes**
  - Admin report/list for LiveStack Event codes.

- **Page 9167: LiveStack Event Details**
  - Admin form for a LiveStack Event.
  - Shows parent values and associated workshop event mappings.
  - Includes override fields and links to regular event-code details where applicable.

### LiveLabs Public App

Relevant pages:

- **Page 400: LiveStack Landing Page**
  - Can load by normal LiveStack ID.
  - Can also load by LiveStack Event code.
  - When loaded by event code, page 400 applies the parent event overrides and only shows the selected active event entries.

- **Page 180: Workshop Event Page**
  - Used when a LiveStack Event entry links to a workshop event code.
  - The entry should open page 180 using the event code when one exists.

- **Page 320: Reservation Flow**
  - Receives the child voucher/event ID through `P320_VOUCHER_ID`.
  - The event code can be set through the existing `WEC` item reference.

## Intended WMS Flow

1. User opens WMS and chooses to request an event code.
2. User chooses **LiveStack Event**.
3. User selects a LiveStack on page 70.
4. The page displays the LiveStack entries.
5. Entries are selected by default for a new event.
6. User can turn individual entries on or off.
7. User enters the event title, dates, timezone, optional overrides, max users, and concurrent users.
8. User saves the page.
9. WMS creates the LiveStack Event parent row.
10. WMS creates regular workshop event rows for selected entries only.
11. Associated workshop events appear in the entry table.
12. Users can edit the generated workshop event rows through links to the regular event form.

## Entry Selection Rules

For a new LiveStack Event:

- Active LiveStack entries should appear after selecting the LiveStack.
- Entries should default to selected.
- Only selected entries should get generated workshop event codes on save.
- Unselected entries should not get workshop event codes.

For an existing LiveStack Event:

- Entries with active generated event rows should appear selected.
- Entries with inactive generated event rows should appear unselected.
- Selecting an entry for the first time should create a generated workshop event row.
- Deselecting an entry should mark its generated workshop event inactive.
- Deselecting an entry should not delete it during normal entry selection changes.

## Changing The LiveStack On An Existing Event

Changing the LiveStack on an existing LiveStack Event is intentionally destructive for the associated workshop events.

Expected behavior:

1. User changes the LiveStack field on page 70.
2. A confirmation dialog warns that associated workshop events will be overwritten.
3. If user cancels, the LiveStack field should revert.
4. If user accepts, WMS remaps the generated workshop event rows to fit the new LiveStack.
5. WMS reuses rows where possible.
6. WMS inserts new rows only when no reusable row exists.
7. Rows that are no longer valid for the new LiveStack are deleted.
8. The deleted rows are not expected to come back if the user later switches back to the old LiveStack.

Important QA note: If a user changes from LiveStack A to LiveStack B, saves, syncs, and then changes back to LiveStack A, some workshop event codes may be newly generated. This is expected because obsolete rows are deleted during remap.

## WMS Generated Workshop Events

When WMS creates or updates generated workshop events, it should set:

- Workshop reference
- Event title
- Valid from and valid to
- Timezone
- Active flag
- Event status
- Max users
- Concurrent users
- LiveLabs URL JSON values from the underlying workshop
- Event configuration JSON values from the underlying workshop

If the parent LiveStack Event dates, timezone, active flag, status, max users, or concurrent users change, the associated generated workshop events should be updated as well.

Title update rule:

- If the child workshop event title still equals the old parent event title, it should update to the new parent title.
- If the child workshop event title was customized, WMS should not overwrite it.

## Approval And Edit Permissions

Expected WMS permissions:

- Event creator can edit their own LiveStack Event.
- Requestor emails can edit the LiveStack Event.
- Event admins can edit any LiveStack Event.
- Only event admins should be able to edit the status.
- If the user cannot edit the event, the LiveStack field should be disabled so the remap process cannot be triggered.
- Creator and requestor emails should be Oracle email addresses ending in `@oracle.com`.

## Sync To LiveLabs

WMS syncs data to LiveLabs through ORDS.

The sync happens in three conceptual parts:

1. **Regular workshop event sync**
   - Sends generated workshop events to LiveLabs as regular event codes.
   - This creates or updates the child event codes used by LiveStack entries.

2. **LiveStack Event parent sync**
   - Sends the parent LiveStack Event values to LiveLabs.
   - Includes event code, LiveStack ID, active flag, dates, timezone, title, overrides, max users, concurrent users, creator/requestors, and remarks.

3. **LiveStack Event entry batch sync**
   - Sends the current mapping of LiveStack entries to generated workshop event codes.
   - LiveLabs updates existing mappings, inserts new mappings, and removes mappings that WMS no longer sends.
   - The batch is treated as the current source of truth for that LiveStack Event.

Important QA note: The parent sync can succeed while the entry batch sync fails. Check both log entries.

## LiveLabs Page 400 Behavior

Page 400 should support two entry paths:

- Normal LiveStack ID
- LiveStack Event code

When loaded by LiveStack ID:

- Page 400 should show the normal LiveStack values.
- The content section should show the normal active LiveStack entries.

When loaded by LiveStack Event code:

- Page 400 should resolve the event code to the parent LiveStack Event.
- Event title and override fields should replace the normal LiveStack values when provided.
- If an override field is blank, the normal LiveStack value should display.
- The content section should only show entries with active mapped workshop event codes.
- Disabled or omitted entries should not display.
- Entry numbering should be relative to visible entries, not raw stored position.

Example: if visible entries have positions 2, 5, and 8, the page should display them as 1, 2, and 3.

## Entry Links From Page 400

Expected behavior for event-mode entries:

- Workshop entries with an event code should link to page 180 using the event code.
- Sandbox/reservation entries should pass the event/voucher ID to page 320 using `P320_VOUCHER_ID`.
- Existing `WEC` behavior can still be used where required.
- If an entry does not have an active event mapping in event mode, it should not appear.

## Subscribe Behavior On Page 400

The normal Subscribe button applies to the public LiveStack, not the temporary event version.

Expected behavior:

- Subscribe button should only display when the underlying LiveStack is public and active.
- If the page was loaded by LiveStack Event code, clicking Subscribe should show a warning that the event may contain different content than the public LiveStack.
- If user confirms, they subscribe to the public LiveStack.
- If user cancels, no subscription change should happen.

## LiveStack Event User Tracking

When a user opens page 400 with a LiveStack Event code:

- LiveLabs tracks that the user entered the parent LiveStack Event code.
- Event creator, requestors, and event admins should not be counted as normal users for this tracking.
- The tracking is used for parent LiveStack Event max user checks.

## Max Users And Concurrent Users

LiveStack Events now have parent-level max and concurrent user fields.

Expected behavior:

- WMS page 70 should allow max users and concurrent users to be entered.
- Generated workshop event rows should inherit those values.
- WMS sync should send those values to LiveLabs.
- LiveLabs should store those values on the parent LiveStack Event.
- Page 400 should block event content when the parent event exceeds its configured limits.

Current implementation note for QA:

- Parent LiveStack Event limits are checked against LiveStack Event user tracking.
- There is not currently a separate parent LiveStack active-session counter.
- The concurrent-user behavior is therefore based on the available parent event usage signal, not a full live session count.

## Common Failure Points To Watch

### Parent Sync Succeeds But Entry Batch Fails

Symptoms:

- Log says parent sync success.
- Entry batch log shows REST error.
- Page 400 may show old entries, missing entries, or no update.

Likely causes:

- Entry mapping references a LiveStack entry that does not belong to the current parent LiveStack.
- Mapping references a workshop event that does not match the entry workshop.
- Duplicate or conflicting mapping IDs.

### Remap Creates New Event Codes

This can be expected.

If the LiveStack was changed, old invalid mappings are deleted. If the user later changes back, WMS may need to create new generated workshop events because the old rows were intentionally removed.

### Disabled Entry Still Shows In LiveLabs

Expected behavior is that disabled entries should disappear after sync.

Check:

- WMS map row is inactive.
- Generated child workshop event is inactive.
- Parent LiveStack Event has been marked updated.
- LiveLabs entry batch sync succeeded.
- Page 400 was reloaded with the correct event code.

### Page 400 Shows Raw Position Numbers

Expected behavior is relative numbering of visible entries.

If an event only shows the third, fourth, and seventh LiveStack entries, they should still display as 1, 2, and 3.

### Event Code Link Opens Wrong Content

Check whether the entry is:

- Workshop
- Sandbox/reservation flow
- Tenancy or other entry type

Workshop entries should use page 180 with event code. Sandbox/reservation entries should pass the voucher ID to page 320.

## Suggested QA Scenarios

### Scenario 1: Create A New LiveStack Event

1. Open WMS page 69.
2. Choose LiveStack Event.
3. Select a LiveStack with multiple entries.
4. Leave all entries selected.
5. Enter title, dates, timezone, max users, and concurrent users.
6. Save.
7. Verify associated workshop events are created.
8. Open a generated workshop event from the table.
9. Confirm it has inherited dates, timezone, limits, and workshop reference.

### Scenario 2: Create With Only Some Entries

1. Create a new LiveStack Event.
2. Deselect one or more entries before first save.
3. Save.
4. Verify only selected entries have generated workshop events.
5. Sync to LiveLabs.
6. Open page 400 by event code.
7. Verify only selected entries display.

### Scenario 3: Disable An Entry After Sync

1. Start with a synced LiveStack Event that has multiple active entries.
2. On WMS page 70, deselect one active entry.
3. Save.
4. Sync to LiveLabs.
5. Open page 400 by event code.
6. Verify the disabled entry no longer displays.

### Scenario 4: Re-enable An Existing Entry

1. Use a LiveStack Event with an inactive generated entry.
2. Re-select the entry.
3. Save.
4. Verify the existing row is reactivated rather than duplicated.
5. Sync to LiveLabs.
6. Verify the entry appears again on page 400.

### Scenario 5: Remap To A Different LiveStack

1. Open an existing LiveStack Event on WMS page 70.
2. Change the LiveStack field.
3. Confirm the warning dialog appears.
4. Cancel once and verify the field reverts.
5. Change it again and accept the warning.
6. Save.
7. Verify associated workshop events now match the new LiveStack entries.
8. Sync to LiveLabs.
9. Open page 400 by event code.
10. Verify the page shows the new LiveStack content and does not show old invalid entries.

### Scenario 6: Change Back To The Original LiveStack

1. After Scenario 5, change the LiveStack back to the original.
2. Accept the warning and save.
3. Verify WMS creates or reuses rows as available.
4. New generated workshop event codes may be created. This is expected if old rows were deleted during the prior remap.

### Scenario 7: Override Display

1. Set event title, description, outline, and prerequisites overrides.
2. Sync to LiveLabs.
3. Open page 400 by event code.
4. Verify override values display.
5. Clear one override field in WMS.
6. Sync again.
7. Verify page 400 falls back to the base LiveStack value for that field.

### Scenario 8: Max User Limit

1. Set max users to a low value such as 1.
2. Sync to LiveLabs.
3. Open page 400 by event code as one normal test user.
4. Open page 400 by event code as another normal test user.
5. Verify the later user sees the oversubscribed message and the event content cards are hidden.

### Scenario 9: Event Admin Bypass

1. Open page 400 by event code as the event creator, requestor, or event admin.
2. Verify the user is not treated like a normal tracked user for limit enforcement.
3. Verify content can still be accessed during valid event dates.

### Scenario 10: Subscribe From Event Page

1. Open page 400 by LiveStack Event code.
2. Click Subscribe.
3. Verify a warning explains that the event version may differ from the public LiveStack.
4. Cancel and confirm no subscription change.
5. Repeat and confirm.
6. Verify subscription applies to the public LiveStack.

## Test Data Guidance

Use clearly named test records, for example:

- Event title starts with `QA LiveStack Event`
- Remarks include tester name and date
- Use short valid date windows
- Use low limits only in Dev

Avoid using production-like public events for destructive remap testing because changing the parent LiveStack can delete obsolete generated child mappings/events.

## QA Completion Checklist

- WMS can create a LiveStack Event.
- WMS can generate child workshop event rows.
- WMS can enable and disable selected entries.
- WMS remap warning behaves correctly.
- WMS remap updates rows for the new LiveStack.
- WMS-to-LiveLabs parent sync succeeds.
- WMS-to-LiveLabs entry batch sync succeeds.
- Page 400 loads by LiveStack ID.
- Page 400 loads by LiveStack Event code.
- Page 400 applies overrides.
- Page 400 shows only active event entries.
- Page 400 entry links go to the correct downstream page.
- Page 400 handles max user limits.
- Subscribe behavior is clear and does not silently subscribe to event-specific content.
