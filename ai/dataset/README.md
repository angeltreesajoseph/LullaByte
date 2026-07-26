# dataset

AI-pipeline-local dataset staging: versioned train/validation/test split
manifests and preprocessed-sample references (SAD Section 11.2) derived from
the raw source dataset in the repository-root `Dataset/` folder. This folder
does not duplicate the raw audio files themselves — it tracks which samples
belong to which split and dataset version, for training reproducibility.
