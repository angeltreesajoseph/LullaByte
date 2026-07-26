# inference

Inference-time orchestration (SAD Section 11.7): the request-facing pipeline
that runs Audio Validation → Baby Cry Detection → Noise Reduction → Feature
Extraction → Classification → Confidence Calculation → Recommendation
Mapping, invoked by the backend's `cry-analyzer` router for every submitted
recording (SRS Section 10.6.3–10.6.11).
