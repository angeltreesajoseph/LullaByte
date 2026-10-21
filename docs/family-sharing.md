# Shared care

## Parent workflow

Profile → Family Sharing → select one baby → enter the recipient account email → choose **Manage care** or **View only** → Create invitation → Copy invitation link. Send the link yourself in your preferred messaging app. No automatic email or SMS invitation delivery is claimed. For twins, create an invitation for each baby you want to share.

The link opens a generic HTTPS landing page, then the installed Android app via `lullabyte://app/join?invitation=<uuid>`. If unavailable, paste the link in Family Sharing. Sign-in/registration preserves the pending invitation within the app process. The intended verified-email account must explicitly accept. Forwarding the link to another account does not grant access. Links expire in seven days; cancel and recreate to renew.

- Owner: baby details, invitations, roles, access removal, care records, chat and reports.
- Manage care: add/edit/delete tracker records and send chat. Cannot change baby identity, ownership or sharing.
- View only: read baby records, photos, audio, reports, activity and chat; cannot change records or send messages.
- Members can decline or leave; owners can cancel, change roles or revoke. Access checks run on every server request, including activity/chat. Sharing includes previous records, not only future activity.

## Activity and chat

Activity & Chat opens a per-baby, server-persisted stream. New tracker saves generate a server-timestamped activity with the authenticated actor's display name. Unchanged saves do not create duplicate activity. Existing pre-deployment records remain in trackers; they are not retrospectively attributed to a caregiver.

Activity/chat refresh every five seconds while open. Home/Overview/Profile check status every ten seconds while foregrounded and fetch a new snapshot only when changed. This is foreground polling, not continuous sensor monitoring or guaranteed instant realtime. Tracker forms are excluded from background refresh so drafts are not replaced.

The latest 100 activity items are displayed. Care records remain available in their dedicated histories. Chat is text-only (2,000 characters), server-persisted, limited to 20 sends/minute, and uses a client UUID to make retries idempotent. Sender/owner can remove a chat message; already read or exported copies cannot be recalled. Chat is not an emergency or medical response service.

Whole-tracker saves carry an `X-Care-Revision` learned from a server read. A stale revision is rejected with 409. Once a baby has an accepted sharing grant, old clients without revision support must update. Refresh before retrying a stale save; do not claim success on conflicts. Versions are cleared at sign-out. All participants need the latest app.

## Notifications

Enable notifications explicitly in Family Sharing on each recipient phone. FCM tokens are bound to the authenticated account and unregistered/invalidated on disable/logout. Android receives a generic notification without baby names, cry predictions or chat text. Care updates notify the parent (not the author); chat notifies other accepted members. The foreground app also shows local notifications. Opening a notification launches the app; open Family Sharing to view activity/chat.

An SQL delivery queue is committed with each activity. The app server's background worker checks every 15 seconds, rechecks recipient access, removes invalid device tokens, and retries failures up to five times with at least a minute between tries. New registrations do not replay old events. Delivery is best-effort and may be delayed or prevented by Firebase permissions, network, OS restrictions, force-stop or Render sleeping. It must not be used for emergency monitoring. At-least-once retries can occur; Android notifications use the event ID as their tag.

Server uses existing Firebase Admin credentials plus the Cloud Messaging API. `LULLABYTE_SHARING_PUSH_ENABLED` defaults to true; set false to disable the worker. `LULLABYTE_PUBLIC_API_ORIGIN` defaults to the existing Render hostname. No third-party email service or Firestore rules are needed. Documentation: [Firebase Flutter setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started), [message reception](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages), [Admin sending](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk).

## Deployment and validation

Apply `python -m alembic upgrade head` from backend with the verified database target before deploying the new server. Revisions 0004/0005 add sharing and contacts; 0006 adds activity/chat, devices and queued deliveries. These are additive migrations; existing babies and tracker arrays are preserved. Never publish credentials.

Test on two Firebase accounts/devices: invitation + verification, isolated twins, view-only denial, caregiver save visible on parent, stale-save conflict, chat and idempotent retry, parent background notification, decline/leave/revoke and logout-device cleanup. Automated tests use an isolated database and mocked push delivery; they do not establish real two-phone FCM delivery.

Revocation blocks future server access. It cannot erase previously downloaded audio/photos, screenshots, exports or currently cached data. Foreground polling clears a revoked selection after access is checked; offline cached data cannot be remotely recalled. No claim of end-to-end encrypted chat is made.
