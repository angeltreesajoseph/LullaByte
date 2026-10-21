# Shared care

Home's top-left baby photo opens the selected baby's Profile. The fourth bottom tab is Chat, showing a separate conversation for every owned or accepted shared baby. Family Sharing's Open chat action opens that same conversation, not a separate message store. Chat bubbles show sender and timestamp, with the sender/parent's remove action in the message menu. There is no fake unread count or demo chat data.

## Parent workflow

Profile → Family Sharing → select one baby → enter the recipient account email → choose **Manage care** or **View only** → Create invitation → Copy invitation link. Send the link yourself in your preferred messaging app. No automatic email or SMS invitation delivery is claimed. For twins, create an invitation for each baby you want to share.

The link opens a generic HTTPS landing page, then the installed Android app via `lullabyte://app/join?invitation=<uuid>`. If unavailable, paste the link in Family Sharing. Sign-in/registration preserves the pending invitation within the app process. The intended verified-email account must explicitly accept. Forwarding the link to another account does not grant access. Links expire in seven days; cancel and recreate to renew.

- Owner: baby details, invitations, roles, access removal, care records, chat and reports.
- Manage care: add/edit/delete tracker records and send chat. Cannot change baby identity, ownership or sharing.
- View only: read baby records, photos, audio, reports and activity without changing care records. All accepted members, including view-only members, can send chat messages and remove their own messages.
- Members can decline or leave; owners can cancel, change roles or revoke. Access checks run on every server request, including activity/chat. Sharing includes previous records, not only future activity.

## Activity and chat

Activity & Chat opens a per-baby, server-persisted stream. New tracker saves generate a server-timestamped activity with the authenticated actor's display name. Unchanged saves do not create duplicate activity. Existing pre-deployment records remain in trackers; they are not retrospectively attributed to a caregiver.

Activity/chat refresh every five seconds while open. The Chat inbox fetches only conversation metadata and pauses its polling while a conversation is open. Home/Overview/Profile check status every ten seconds while foregrounded and fetch a new snapshot only when changed. This is foreground polling, not continuous sensor monitoring or guaranteed instant realtime. Tracker forms are excluded from background refresh so drafts are not replaced.

The activity screen displays the latest 100 activity items; direct conversations fetch the latest 100 chat messages independently of care activity. Care records remain available in their dedicated histories. Chat is text-only (2,000 characters), server-persisted, limited to 20 sends/minute, and uses a client UUID to make retries idempotent. Sender/owner can remove a chat message; already read or exported copies cannot be recalled. Chat is not an emergency or medical response service.

Whole-tracker saves carry an `X-Care-Revision` learned from a server read. A stale revision is rejected with 409. Once a baby has an accepted sharing grant, old clients without revision support must update. Refresh before retrying a stale save; do not claim success on conflicts. Versions are cleared at sign-out. All participants need the latest app.

## Notifications

Recipient policy: care-record updates go to the parent and accepted Manage care members; chat messages go to the parent and every accepted member, including View only. The author is excluded. Current roles are checked again before queued push delivery and when loading the inbox, so a downgraded viewer no longer receives or sees care-update alerts. This does not change anyone's chat or care-record permissions.

The Home bell opens one inbox with All/Unread filters and Today/Earlier groups. Shared-care alerts are server delivery records, independent of whether a phone has push enabled. Read state is saved per recipient in `care_deliveries.read_at` (migration `0007_shared_alert_reads`); reading does not change push delivery status. Deleted messages and revoked access are excluded. While browsing older pages, automatic refresh pauses rather than discarding history; Refresh latest deliberately returns to recent alerts. Mark-all uses the displayed snapshot cursor. Alert taps validate current baby access before opening the existing tracker or chat. The badge counts real shared unread alerts plus accessible local due reminders.

Chosen feeding/vaccination reminder times are saved on this phone, scoped by account, deduplicated by baby/type/record/time, and shown only when due and still authorized as owner/manager. These entries say a reminder is due, not that the OS delivered it. Future cancelled reminders disappear; already-due history remains (up to 500 entries). Read status for these local reminders is per phone, not server-synchronized. Reinstalling/clearing app data removes local reminder history; shared alerts remain server-backed. No automatic catch-up medical advice or fabricated cry predictions are added.

Family Sharing uses one selected-baby dropdown for the care team and pending invitations. Only the parent sees the invite button and member permission/removal menus. The invitation form opens on demand; manual link entry is collapsed under “Have an invitation?”. Chat stays in the bottom Chat tab, without duplicate activity/chat cards here. Existing stored activity/messages are not deleted. Accepted non-owner accounts see their own grant (the API intentionally does not expose other members' email addresses).

One notification switch shows the saved account preference on this phone together with OS authorization; it refreshes when the app resumes. It applies to all shared babies, not just the selected baby. Failed registration does not leave the switch claiming successful enablement.

Enable Shared care alerts explicitly in Family Sharing on each recipient phone. FCM tokens are account-bound and unregistered/invalidated on disable/logout. Lock-screen shared pushes contain generic text, not baby names, cry reasons or chat content. Care updates notify the parent and accepted managers (excluding the author); chat notifies other accepted members. Shared phone taps resolve the saved event through an authorized inbox target, including alerts outside the newest page. Foreground local, background FCM and cold-start taps are wired. Local reminder taps carry account/baby/reminder identifiers; wrong-account taps are discarded. Signed-out taps wait until login. An expired/revoked target shows an unavailable message, not private data. Dismissing a drawer notification does not delete inbox history. This requires the updated app and backend; existing scheduled notifications without payloads cannot deep-link until schedules are restored.

An SQL delivery queue is committed with each activity. The app server's background worker checks every 15 seconds, rechecks recipient access, removes invalid device tokens, and retries failures up to five times with at least a minute between tries. New registrations do not replay old events. Delivery is best-effort and may be delayed or prevented by Firebase permissions, network, OS restrictions, force-stop or Render sleeping. It must not be used for emergency monitoring. At-least-once retries can occur; Android notifications use the event ID as their tag.

Server uses existing Firebase Admin credentials plus the Cloud Messaging API. `LULLABYTE_SHARING_PUSH_ENABLED` defaults to true; set false to disable the worker. `LULLABYTE_PUBLIC_API_ORIGIN` defaults to the existing Render hostname. No third-party email service or Firestore rules are needed. Documentation: [Firebase Flutter setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started), [message reception](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages), [Admin sending](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk).

## Deployment and validation

Apply `python -m alembic upgrade head` from backend with the verified database target before deploying the new server. Revisions 0004/0005 add sharing and contacts; 0006 adds activity/chat, devices and queued deliveries. These are additive migrations; existing babies and tracker arrays are preserved. Never publish credentials.

Test on two Firebase accounts/devices: invitation + verification, isolated twins, view-only denial, caregiver save visible on parent, stale-save conflict, chat and idempotent retry, parent background notification, decline/leave/revoke and logout-device cleanup. Automated tests use an isolated database and mocked push delivery; they do not establish real two-phone FCM delivery.

Revocation blocks future server access. It cannot erase previously downloaded audio/photos, screenshots, exports or currently cached data. Foreground polling clears a revoked selection after access is checked; offline cached data cannot be remotely recalled. No claim of end-to-end encrypted chat is made.
