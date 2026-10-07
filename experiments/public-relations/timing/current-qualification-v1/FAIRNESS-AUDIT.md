# Strict timed-work audit

Source equality and complete output equality establish semantic reuse. They do not establish equal timed work. The existing matched53-file candidate is a complete application/observer diagnostic, not a fair isolated ECS qualification.

| Work | Bend timed body | bevy-ts timed body |
| --- | --- | --- |
| Factory/world/schema and owner initialization |Included |Included |
| Actual registered systems, component/relation queries, writes, failures, deferred commands/barriers and linked cleanup |Included |Included |
| Shared public query rows, ordered relations, notices and retained values |Materialized and formatted as strings |Materialized as DTOs |
| Additional physical component owners, unused slots, stamps, liveness, allocator/system/World/queue metadata |Projected and formatted at checkpoints |No corresponding physical dump |
| Serialization |Recursive Bend show/concatenation |JSON.stringify |
| UTF8/newline/FNV capture and buffer retention |Included |Included |
| Full chronological model comparison and physical-output validator |Outside child/timer |Outside child/timer |
| Process imports/startup and final output flush |Outside region; separate process metric |Outside region; separate process metric |

Bend `application.bend` calls its query observation and then `C.observe`; `owned-world.bend` additionally scans physical Array cells and stamps and serializes topology/World metadata. TS `reference.mjs` captures public query/lookup/failure/removal DTOs, then JSON.stringify serializes them. Historical scale-one captures contain49569 Bend bytes and88020 TS bytes. Both serialize substantial data, but different fields and encodings make capture/observer cost unequal. The already-delivered projection/capture optimization improves this diagnostic overhead; its profiles do not prove an ECS operation speedup.

The existing120 pairs time the whole fresh lifecycle, including initialization, registration/observation and output materialization. They exclude startup/flush, so they are not startup-only numbers. They retain complete outputs and genuinely execute ECS. Nevertheless they are old-implementation descriptive observations and cannot meet the current optimized full-qualification goal. Candidate single instrumented profile durations also include profiler/flush/drain effects and are not paired evidence.

## Minimal fair replacement before any comparison

Preserve the existing fixtures/receipts unchanged. Author a new matched adapter, not an output-filtered old timer. Both roles must time the same public ECS operation sequence: actual registered writer/reader execution, required/optional/with/without/multi-descriptor queries, full selected payload projections, reads/writes, deferred publication/application, rejected relation/failure handling, rollback and linked/ordinary cleanup. Immutable shared checkpoint snapshots and retained query values remain real values produced by those operations. Removing queries, payload cells, failed writes, future-target work or cleanup is forbidden.

Keep shared snapshot field materialization inside the operation region where necessary for the actual query contract. Return typed shared Data snapshots in Bend and independent immutable DTOs in TS, then serialize, UTF8/capture/FNV, flush and validate outside that region. Bend must return every affine world/column/resource owner; a checksum or collapsed result cannot replace that ownership path. Required schema/setup and registration costs should be reported separately for the same setup, with an additional complete-lifecycle application metric if needed; moving them outside an update region must never be labeled a whole-application speedup.

Full Bend-only physical diagnostics must remain checked at every original checkpoint outside the timer. This needs explicit reviewed pause/resume regions or typed checkpoint snapshots around the actual operations, because observing only the final world loses historical owner/stamp evidence. Record the possible cache/allocation perturbation of off-clock diagnostics. Do not fabricate TS physical fields or subtract measured observer estimates from old timings. Inspect actual emitted JS/C effect ordering before enrollment and validate every complete actual sample outside the clock against the unchanged independent chronology.

## True scaling, not repetition

Freeze independent input fixtures that vary one dimension at a time: logical entity population (including empty/sparse/non-power-of-two worlds), incoming fanout, hierarchy depth and relation descriptor count. Keep other dimensions and the per-entity operation schedule fixed within each family. Use the same logical authored world and actual operation/output counts on both roles; physical capacities are backend-specific and recorded. Preserve relation-only entities excluded by required component selection, ordered inverse snapshots, complete payload cells and linked cleanup. Population fixtures need full independent expected outputs before runtime, not multiplication of the old small-world output.

Start from the existing small four-component/five-then-six-entity, three-descriptor subject as a correctness anchor; use already represented finite graph sizes and approved existing storage benchmark populations when preparing concrete growth inputs. Exact fixture sizes, per-case output/command/selected-row/edge/cleanup counts and stage bytes must be frozen and reviewed. This audit does not introduce a numerical performance threshold or select a new baseline. The current1/2/4 repeats can remain a separate lifecycle repetition diagnostic, but cannot satisfy these growth families.

Once the replacement's complete cheap consumers and source/effect/fairness review pass, reuse unaffected semantic mutant/core evidence through explicit byte joins. Run only the newly affected fixture correctness/backend gates. Then enroll one candidate/fresh-TS paired cohort using unchanged approved pairing settings and targets, only in an admitted host window. No new before/after profiles are justified until there is an actual consequential optimization change.

## Fresh anchor correction

The historical mutable TS writer traverses `each()` before selecting entity 3, whereas the original Bend writer directly set entity 3. Visiting TS mutable cells does not mark them changed; only their setter journals/marks the selected write. The additive public-trace anchor now traverses real Bend live handles/component membership, performs the selected write in traversal order, and then visits remaining handles. Full phase5 rollback remains observed. Native/JS complete anchors and boundary controls qualify this finite corrected operation sequence, not the older timing ratios. See TRACE-ANCHOR.md and trace-source-join.json.
