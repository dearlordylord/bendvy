# Ordinary recoverable resource field — first consumer

This bounded #61 composition extends the existing #52 replacement/swap contract
to an Array field selected by an ordinary `resource-field-binding.Binding`.
The candidate is `ordinary-recovery-resource-field.bend`; root materialized its
body at the canonical `src/ecs/ordinary-recovery-resource-field.bend`, normalizing
imports only. The consumer imports that actual canonical module. It does not run
a private adapter followed by a second canonical backend qualification.

The declaration composes the Capture/World product lens, existing World resource
lens and the canonical Binding field lens. The same Binding couples the nominal
resource identity and physical path; access derives from that identity. Existing
`recoverable-array-owner` creates every replacement/swap inverse and the existing
ordinary runner owns the single journal. Gameplay receives opaque grants, with
no raw World, authored inverse or separate recovery journal.

The ordinary resource declaration tree contains target `Array<Array<U32>>`, an
untouched sibling of the identical payload type and a separate `Array<U32>` owner.
The nominal Workshop/Garden runs each create an actual IO World. Target seed10,
same-payload sibling800, unlike owner900 and registered capture700 have distinct
complete physical trees. Capture is retained unchanged by this sole resource
field grant; this fixture does not add opt-in capture mutation.

The first call commits seed100. The second uses seed200 and fails after replacing
the target, swapping index1, replacing it again and refusing an index99 swap.
The actual rollback records return in authored order: Replaced(first),
Swapped(index1,element), Replaced(second), while Output returns the refused owner.
After complete observation, `recover_retry` reconstructs Args from those exact
returned values. A failed retry and successful retry consume these returned
Arrays, changing only the failure Bool. The actual returned Registry/World/capture
also pass directly to the next call. No seed300/400 literals substitute for retry
payloads. Commit records preserve displaced originals; failed calls restore the
previous committed target and return displaced replacements.

`observe.bend` reconstructs all inspected owners: nested physical Array trees,
all sibling/capture owners, World allocator/liveness/store/resource/events,
unchanged pending callbacks and their count, registration metadata, clock and
Registry cursor. Complete Args, Output and record variants/index/payloads are
observed before reuse or explicit release. Success/failure/refusal and terminal
snapshots remain distinct. This resource-only fixture has empty pending/events,
Unit store and zero clocks/cursors; it does not qualify nonempty queues, component
stamps or clock advancement. Foreign/schema/access controls and reached mutations
remain subsequent gates after the first complete normal pair.

`SOURCE-FREEZE.json` binds the actual 67-module non-Base import closure and 138
source pins including Base/foreign sidecars. `SOURCE-CHECK.json` records exact
CPU5 commands, unchanged five-second wrapper limit, raw stdout/stderr and pre/post
pins. Pure adapter, fixture, observer and scenario check successfully. Concrete
IO main exits1 with exactly five expected unsafe/foreign IO definitions, matching
the existing #52 IO-source boundary; no parser/type/affine error occurs. This is
not a whole-entry checker PASS. No backend run or observed stdout was used here.
The independent source oracle is authored separately before execution.

Bend skills and existing #52 Spec/Standards criteria govern this implementation.
No new contract, law, proof, cleanup/finalization policy, clock rule, dependency,
runner or limit is introduced. Raw Binding/lens/declaration/Frame builders remain
trusted schema/engine provisioning; ordinary gameplay does not receive them.
Full correctness/control review, source-bound protected #28 applicability and
root integration remain delivery gates. Combined timing/scaling and final
JS <= TS / Native <= 0.5 * TS stay with #21/#23/#24; #61 remains incomplete.
