# Public identity #38 — independent-root discovery

Run `python3 experiments/public-identity/run-root-controls.py`. The fresh guarded fixture creates two actual same-schema worlds, reserves entity1 and activates it in each. Independent calls to the existing public factory produce namespace1 in both; actual World.valid accepts the sender handle in the receiver on JS and Native. A shared affine Factory control produces distinct namespaces and rejects it.

The retained receipt is EXPECTED_IDENTITY_FAILURE_CONFIRMED, not a passed #38 gate. This confirms the already documented independent-root limitation of the bounded API; historical shared-factory foreign controls remain scoped evidence. No executable core was changed by this discovery.

## Concrete design boundary

Rust Bevy WorldId uses a checked process-local atomic allocator and does not reuse an identifier after disposal. Bend closures/owners are affine; a pure independently restarted Factory cannot produce globally unique runtime namespaces. A canonical independent-world creation seam therefore needs either one explicitly owned host allocator or a checked IO namespace effect. Random/time tokens do not establish exact uniqueness. Existing raw constructors remain a trusted admin boundary, not secrets.

Before selecting the next creation API, distinguish supported factory roots, legacy raw construction, process lifetime, namespace exhaustion and stale handles/restore. Do not claim raw caller-fabricated identities are safe or silently impose a new reuse/capacity policy. Keep monotonic/no-reuse prototype limits as historical until the production domain is explicitly resolved. The next implementation must execute actual lookup/commands and prove no receiver queue mutation on foreign refusal, including independently created supported worlds.

No new law, proof, dependency, compiler/runtime patch or performance result is introduced. Checker/runtime5, emission30 and Native compilation120 caps are retained. The source-derived WorldId architecture is not a universal Bend runtime proof.
