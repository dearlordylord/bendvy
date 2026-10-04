# Astra review — next core checkpoint

Read-only review by gpt-6-astra of T10/T11 and next-core-checkpoint, against SPEC.
The reviewer found the draft suitable for human discussion and retained full-core,
affine payload, performance and refinement boundaries. No approval was inferred.

| Finding | Resolution / evidence |
| --- | --- |
| T10 count/sum allowed no-op churn/rollback and hid order | Measured workload revised: removal records counted after each marker, own attempted values read before rollback, ordered final slot/value projection compared. All 18 timing cases and RSS freshly remeasured. Separate compiling no-op controls now pass on native/JS with original/TS positive controls |
| wait4 RSS includes inherited Python launcher peak | Observer/report now disclose pre-exec launcher floor; native number is not interpreted as runtime-only footprint |
| Zero-round values were called medians though collected once | Report corrected to measurements; no subtraction or precision claim |

T11 has 14 general draft statements, 330 finite original instances and 14
separately typechecking mutants rejected at their own statements. This is literal
falsification evidence, not universal proof or runtime refinement. P-TX/P-PROVIDE
and simulation remain outlines; exact laws/input/output/dependency specifications
must precede published ready-for-agent implementation/proof tickets.

The revised T10 run and its own-path no-op controls passed; both material
findings are resolved within the explicitly bounded measurement report. User review/approval of exact laws, thresholds and next-stage
breakdown remains pending. Astra did not rerun the full benchmark/falsifier.
