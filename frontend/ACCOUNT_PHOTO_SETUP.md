# Account profile photos

Photos now use the existing authenticated API/database, not Firebase Storage.
Names and sign-in email remain in Firebase Auth; the email is read-only here.

Deploy the account router/schema/model changes and apply migration
`0008_account_photos` before installing the new client. The migration creates a
separate `account_photos` table; it does not change baby records or the user table.

`GET /api/v1/account/me/photo` loads the signed-in account's photo.
`PUT /api/v1/account/me/photo` replaces it; explicit `photo_data: null` clears it.
No user ID is accepted. Photos are only returned by this dedicated authenticated
endpoint, not with the baby lists or routine authentication queries.

JPEG/PNG data URLs are capped at 500,000 characters (approximately 375 KB binary).
The client downsizes gallery picks and only reports success after the server
confirms the save. Existing Firebase Auth photo URLs remain a fallback for older
accounts. Photo writes and Firebase name changes are separate operations: if a
name update fails after a photo save, retry or reload the account.

No Firebase Storage rules or paid storage setup are required for this flow.
Production deployment and migration require explicit approval.
