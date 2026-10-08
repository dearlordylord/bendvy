# Fixed-step public TS reference — #63

#63 remains incomplete. This development reference runs ordinary pinned bevy-ts ECS operations in two independently bound schemas and observes 14 complete checkpoints per schema. It does not implement Bend, establish affine cleanup, qualify Native, or measure performance.

The seeded inputs are fixed in `inputs.json`: three entities move by integer fixed steps toward position 2, take one point of damage, publish hit/death events and queue despawn. Explicit barriers materialize spawn and apply despawn. Two independently registered event readers observe complete ordered event batches; ReaderB fails once, its external host journal remains appended, and its subsequent successful run receives the same batch again. That host journal behavior is a TS observation, not a new Bend capture or event ownership contract.

Every checkpoint compares the complete public Debug world dump, including all live component values, resources, pending-command descriptions, frame/tick and entity count, plus complete cumulative reader journals and the tick result. This exposes pending visibility before each barrier. Internal stream queues, affine payload owners and reader registries are not inferred from Debug.dump.

The first cheap run failed because the preauthored oracle counted system and marker ticks but omitted the extra tick on successful nonempty event publication. Pinned `Runtime.ts:1027–1035` advances the World tick once for the complete emitted batch. Only 11 tick fields per schema changed; all other observations matched the initial oracle. Original source, complete stdout/stderr and INCOMPLETE receipt remain in `evidence/failed-oracle-v1`.

The corrected affected consumer passed once: CPU 5, Node-only, five-second cap, exit 0, no supervisor failure, empty stderr, full 19,258-byte stdout SHA-256 `9aea2ef9b3157f12f7c6da92513a3887cdf4b152b39324a005bfb4374fee6fd3`. Both attempts produced that identical complete stdout; the corrected oracle matched it. See `evidence/corrected-oracle-v1`. Receipt source/tool/environment hashes and absolute paths describe these historical executions; they are not a portable current-root certification.

Reference heads checked against `.references/sources.json`: bevy-ts `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` supplies the actual executed public APIs and reference ticks; Rust Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60` remains the architecture authority; Bend `a950fd683c0d76f09794078e6174fe98a1492876` remains the type/affine/runtime authority for the forthcoming implementation. No Rust or Bend execution is claimed here.

Next: implement the same complete application through Bend's public ECS, with arbitrary affine payload cleanup and unchanged independent-reader/failure/barrier behavior; add reached omission/barrier controls, JS/Native observations and the governing performance gates. Existing #35/#41 prerequisites and #63 acceptance remain unchanged.
