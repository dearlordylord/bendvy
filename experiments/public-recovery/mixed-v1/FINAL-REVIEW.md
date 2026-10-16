# #52 joined final review

**Verdict: PASS for the reviewed semantic implementation and evidence.** I found no blocking Spec or Standards defect in the additive resource leaf, heterogeneous declaration composition, mixed consumer, or the joined source-bound evidence. This is not a universal proof and makes no comparative performance claim.

## Source and recovery path

The resource leaf is e3850d8bd; it derives the resource key and lens from the canonical schema/World resource split, and routes whole-Array replacement and indexed element exchange through the existing inverse/journal code. Its payload remains P:Type. Heterogeneous operation composition is in 05da8ceac with the component-family helper 17f799e64; the mixed source is frozen at 6edf49e86.

The mixed callback composes two unlike component families, an explicit capture, and the Array resource through nested D.both declarations. All grants thread the same Frame and journal; the caller receives no inverse, lens, or journal. Its nine interleaved operations cover complete resource replacements, element exchanges, two component families and capture. It sequences prior commit, two failed calls, retry, absent-component rollback, and an actual foreign-world refusal across two nominal schemas. The observer includes both Worlds, component payloads/stamps, resources, captures, returned arguments/outputs/recovery rows, cursors and registry state.

## Evidence reviewed

The mixed stock JS and Native receipts both report COMPLETE_CONSUMER_DEVELOPMENT_PASS, all five commands exit 0, consumer stderr is empty, and all 17 guards are unchanged. Both full streams are 16,673 bytes with SHA-256 eafbb20bd659eea32a9dcbfb65aabb1d10cea1ad99285e8a609d825af6c035e8. I independently ran the pinned source-only oracle; it reproduced that exact length and hash. The execution packet is commit 8b7bac99e (451 path bindings, 415 compressed objects, and 22 explicitly external ELF identities).

Mixed authority packet d1f9b713d plus provenance correction 09ebcd49a has one positive actual F.run and ten intended type/affine negatives: owner duplication, cross-schema run, wrong component identity/leaf grant, wrong resource identity/grant, World and Frame escape, raw World resource mutation from opaque H, and an IO callback where the capture operation requires an owned Array. The retained diagnostics fail at the intended type boundary without parser errors or deadline failures. This tests the ordinary authored rank-2 grant boundary; raw D.Declaration, custom builders/ops, schema provisioning and raw Frame/journal constructors remain trusted engine composition, as documented. It does not claim universal confinement over trusted administration.

The prior ordinary resource slice (6,951 bytes), component/explicit-capture slice (13,009 bytes), and reached resource owner-loss counter (6,631 bytes, rejecting the complete normal trace) remain in scope. The owner-loss mutant drops a displaced owner in the actual commit inverse; it is a finite reached semantic defect control, not evidence of physical object identity or finalization. Actual TS references cover overlapping resource and ordinary captured-value scenarios only; they do not qualify affine owner/inverse semantics or claim TS implements the new opt-in recovery API. The protected default #28 applicability bridge retains the unchanged 23-source workload; no new timing result is asserted.

## Limits before public closure

The accepted recovery surface is the ordinary canonical component/resource/capture operations and their derived inverses. Independent host IO, arbitrary destructive callbacks, automatic finalizers, physical-memory identity, and arbitrary caller-authored inverse builders are outside the guarantee. Full comparative timing/scaling remains under #21/#23/#24; the separate final JS/TS and Native/TS goals remain unchanged.

The current docs/parity/recovery.md still has open checkboxes and ends before the mixed slice. Update it with this evidence and the explicit trusted-engine boundary, record the source-current #28 reuse and TS scope, and state the remaining delivery steps before marking/closing the issue. Integration, configured CI, push, and the governing issue completion report remain delivery gates.
