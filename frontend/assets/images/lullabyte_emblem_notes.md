# Emblem-only app icon

Workspace asset: `frontend/assets/images/lullabyte_emblem.png`.
Android copy: `frontend/android/app/src/main/res/drawable/lullabyte_emblem.png`.
The original supplied wordmark image is retained unchanged.

Created with the built-in image-generation/editing tool (imagegen skill), then
visually inspected. This is an edited bitmap, not an exact vector extraction.

Initial edit prompt: Remove all lettering from the supplied LullaByte logo,
retaining only the original lavender crescent moon cradling the smiling pink
baby. Preserve shapes, face, pastel colours, gradients and proportions. Center
on a transparent square with safe margins for an Android launcher. No text,
new elements, shadow or watermark.

Follow-up prompt: Clean background residue and stray pixels outside the emblem,
preserving the emblem shape, face, colours and interior white swaddle line.
Use a genuine transparent background and smooth outline, with no text.

Android launcher and native splash use the emblem only. Flutter renders the
full name and tagline as text, independently of Android's icon clipping mask.
