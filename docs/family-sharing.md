# Family Sharing

Real per-baby, in-app invitations replace the former sample screen. No email/SMS invitation delivery, live sync or family push alerts are implemented or claimed.

- Owner selects exactly one baby and recipient account email. Twins are separate grants.
- Recipient signs in, opens Profile > Family Sharing, verifies the invited email using Firebase, refreshes and accepts. Pending invitations expire in seven days; cancel and recreate to renew.
- View only can read the baby's records, photos, audio and export reports. Caregiver additionally can add/edit/delete tracker records. Only the owner can edit baby identity/profile or invite/change/revoke members.
- Members can decline or leave. Owners can cancel pending invites, change roles and revoke.
- Accepted babies appear in the existing baby list and dashboard selector. Refresh screens to load updates; this is not realtime collaboration. Existing tracker saves replace a whole tracker list, so avoid simultaneously editing the same tracker from multiple devices.
- Every server read/write checks accepted grants. Revocation blocks subsequent server access; it cannot erase screenshots, exports, already downloaded or currently cached data. A backend authorization error must not be treated as successful saving.
- Unverified accounts cannot view incoming invitation details or accept invitations. No invitation tokens are exposed.

## Deployment

Deploy backend code, then from `backend` with the intended database configured run `python -m alembic upgrade head` (adds revision `0004_baby_sharing`). Deploy/restart backend and rebuild Flutter. Do not run a production migration without checking the database target and backup policy.

Test with two separate Firebase accounts/devices: owner creates invitation; recipient verifies email/accepts; shared baby appears; viewer write is denied; caregiver tracker save is visible after owner refresh; other twin stays private; revoke and verify a subsequent read/write fails. Also test expiration, decline and leave. No production deployment/migration is performed by these local code changes.
