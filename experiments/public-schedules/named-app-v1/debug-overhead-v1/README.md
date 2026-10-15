# Named-plan debug overhead entry

`main.bend:run_mode(count,debug)` and `reference.mjs:runMode(count,debug)` execute the same complete 26-action scene for Workshop and Garden, selecting the debug flag before each fresh World/runtime is created. Both retain ordinary state writes, failure/retry, shared registration state, separate registration, replacement/removal/refusal, descriptions and access indexes. Nothing is filtered from an already executed complete lifecycle.

The Bend entry reuses the frozen matched scene directly. The TS source has the exact frozen matched-reference prefix plus a per-mode entry. Scale 1/2/4 contain 52/104/208 full records. Independent source-only per-mode oracles are required before backend execution. Current source check reaches only expected foreign/IO refusal; this is parser/type/affine evidence, not proof or runtime qualification.

The full matched `run(count)` and all its existing source/model/runtime evidence remain unchanged. Native affine owners/cursors and TS captured state remain their explicit, separately qualified physical boundaries. No measurement, comparative verdict or new performance criterion is claimed here.
