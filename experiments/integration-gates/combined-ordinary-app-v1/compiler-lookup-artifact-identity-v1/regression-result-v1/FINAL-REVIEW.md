# Independent bounded review

Date: 2026-10-16

## #54 protected-workload compiler comparison

Reviewed immutable result commit `577e9f295c391ccfe585ce21a5c0e5238c006c35` in `inspect54-protected-artifact-bridge`, specifically `compiler-lookup-artifact-identity-v1/regression-result-v1/`. The archive SHA-256 is `3d16fa65b7c8442b11653695c6042111dbccc50614353a251bac96a14b6f067a`; manifest SHA-256 `47c3e65f3192d42dbda7d252494896f2691253972bc6ec2518e25608a25b3694`.

**PASS for the two bounded comparison results.** I independently checked all 946 archive members against the manifest, all 123 default and 115 targeted command exits, and all 220 full output streams against the receipt hashes. Each comparison reports `NO_CONFIRMED_REGRESSION` under the existing 20-pair, two-warmup, seeded-order, one-sided paired-sign/Holm contract with zero allowed slowdown. Default #28 Native had 10/20 slower pairs (p=.5881; median ratio 1.0085); targeted retained-artifact Native had 7/20 (p=.9423; median ratio .9597). The final JS and Native outputs matched their role-specific complete oracles. The existing result correctly labels the 5-second CPU-11 admissions as qualitative and the ratios as scoped measurements.

The targeted comparison is same-source old/new compiler artifacts, not the default #28 source-baseline comparison. Candidate JS artifacts were identical and measured; the Native ELF differs (3,104,792 bytes versus 3,170,288 bytes), so the Native route was measured rather than waived. This supports only the recorded protected workload and targeted artifact result. It does not qualify #54’s full workload, establish universal speedup, or select/adopt the copied compiler. The Native artifact difference and the remaining #54 full-consumer gates remain material.

## #61 AppA later resource-failure slice

Reviewed source commit `e2a0017a3`, plan/evidence binding commit `e2c7ce6a7`, independent model commit `58c352eda`, and actual-pair retention commit `210b35913` in `audit61-app-a-resource-failure` / `audit61-app-a-failure-oracle`. The archived manifest SHA-256 is `26cfe223adac8c00861cca74f7744820947475f415f5b8a619421cec67b06d2f`.

**PASS for this bounded failure-path delivery.** The fixture runs a successful Scalar transaction before a Counter resource-field transaction that writes then returns failure. The existing transaction code applies the recorded inverse on failure; the source-derived oracle therefore expects Counter `[10,11]` restored, Sibling `[100,101]` unchanged, the earlier Scalar commit retained, resource-system cursor unchanged, and the failed schedule to stop before the second barrier. The report retains the actual `ResourceFailed` error and full owner/world observations. No shared ECS source changed.

I independently checked all 433 distinct compressed objects against their raw byte counts and SHA-256 hashes; the 22 external installed-tool paths are explicitly identity-only. Both plan/receipt joins and all command exits pass. JS and Native each produce exactly 5,281 bytes, SHA-256 `2ef926dd7fc931df61c36f3135562f88345d79a60174416a8032af1022ba9a82`, with empty stderr; all 17 guards are retained. The model is bound by source hash and reproduced in an isolated sibling layout; the packet does not claim the backend executed the model as an input.

This does not close #61: it covers one AppA failure scenario and makes no arbitrary-Type inverse, broad capability-census, independent-composition, or performance claim. The broader audit gates remain open.
