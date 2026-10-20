# Vaccination tracking

## Scope and clinical limitations

India government UIP infant/toddler suggestions, birth through 24 months.
Reviewed against MoHFW annual reports 2024–25 and 2025–26, including fIPV dose 3.

Sources:
- https://notto.mohfw.gov.in/WriteReadData/Portal/News/951_1_Annual_Report_of_the_MoH_FW__2025_-_2026.pdf
- https://mohfw.gov.in/sites/default/files/Final%20Printed%20English%20AR%202024-25.pdf
- https://ncvbdc.mohfw.gov.in/index1.php?Background=Dark&font=Normal&lang=1&level=2&lid=3759&sublinkid=5922&theme=Cream

These are DOB-based suggestions, not appointments or catch-up recommendations.
Age windows use their starting date for the suggestion and display their end.
Birth hepatitis B and OPV zero-dose timing need particular clinical attention.
JE doses default to not included because they apply to endemic areas; confirm
with the paediatrician before including. No doses are automatically marked done.
Vitamin A is supplementation, not a vaccine, and is not included. Later childhood
vaccinations are outside this infant/toddler screen; custom entries are supported.

## Behaviour

- Suggestions are derived from DOB whenever this screen is loaded. They are not
  prewritten into every new profile; user changes save the merged checklist.
- Each dose has a stable id. Tapping its checkbox records receipt today directly;
  use Edit details for an earlier actual date. Dates cannot be in the future or
  before birth. Unchecking directly clears the received date and reminder.
- Add/edit a custom dose, doctor/clinic, notes and planned/received date. Delete
  custom doses with confirmation. Suggested doses can be marked not applicable.
- Correcting DOB recalculates unmodified suggestions. Explicit planned-date
  overrides and historical actual received dates are retained for review.
- No blank appointment card or misleading “0 remaining” empty state.
- Saves are ownership-scoped under `tracker_data.vaccinations`. Twins' checklists
  and reminders remain separate. Checkbox updates are optimistic and roll back
  on save failure. The edit form stays open with its entered values when saving
  fails. Persistent error messages distinguish missing backend support.

## Reminders

Reminders are opt-in per planned dose, not scheduled silently at profile creation.
Choose a future date/time in IST and grant notification permission. The reminder
editor allows direct changes or removal. Changing a planned vaccination date
clears the previous reminder so a new time can be chosen. Completing,
excluding or deleting a dose cancels its reminder. Future reminders are restored
for all babies after Home reloads from the backend following login. Logout
cancels that user's vaccination reminders. Other notification types are untouched.

Uses inexact Android scheduling, so battery restrictions/permissions may delay
delivery. Android scheduled-notification and boot receivers are configured;
reboot and physical-device delivery still need real-device testing. Server-stored
reminder preference does not guarantee native notification delivery. No push
notification worker or SMS service is used.

## Deployment and tests

Backend must deploy the new vaccinations tracker kind/schema before app saves
will work. No new database migration is needed. Flutter needs a full rebuild for
the Android manifest changes; hot reload alone cannot enable reboot receivers.

Run from frontend:
`flutter test test/vaccination_schedule_test.dart test/vaccination_reminders_test.dart`

Run from backend:
`.venv\Scripts\python.exe -m pytest tests/integration/test_babies_api.py -q`

Tests cover calendar arithmetic, stable identifiers, completion/DOB overrides,
conditional JE, independent twin records, validation and deletion, native channel
scheduling, completion cancellation, logout cancellation and login restoration.
