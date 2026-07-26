# Dataset — Raw Infant Cry Audio

The raw, labeled infant-cry audio dataset used to train the AI Cry Analyzer classification model (SRS Section 4.3 Cry Category Reference; SRS Section 5.2; SAD Section 11.2 Dataset Pipeline).

## Category Folders

| Folder | Cry Category (SRS Section 4.3) |
|---|---|
| `belly_pain/` | Belly Pain |
| `discomfort/` | Discomfort |
| `hungry/` | Hungry |
| `noise/` | Non-Cry / Noise (used to train Baby Cry Detection and Non-Baby Sound Detection, SRS Section 10.6.4–10.6.5) |
| `tired/` | Tired / Sleepy |

This is the **source** dataset. `ai/dataset/` tracks versioned train/validation/test split manifests derived from these files; it does not duplicate the audio itself.
