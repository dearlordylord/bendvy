# Approved affine owned schedule — partial proof milestone

Exact revised statement approved in the [delegated decision](../../docs/reviews/delegated-owned-law-approval.md),
proposal SHA256 `8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b`.
The complete nonempty schedule theorem remains **open**. This package does not
change the original catalogue, frozen proposal, core or domain.

`empty.bend:empty` inhabits the exact revised statement specialized only to the
empty step list, for every live affine `R.World` and both branches of its original
`S.run_safe` guard. It supplies its own actual observation equality; there is no
extra proof premise, empty-row restriction, leaf/balanced-array premise or Data
replacement world. It consumes the actual owned input once.

`capture.bend` obtains dependent cell/list/world frames: actual returned owners,
Data projections, ties to runtime observation calls and independent O observations,
and contextual original-owner equalities. `arrays.bend` derives size/read owner
evidence structurally for arbitrary Array trees and indices. `point.bend` derives
actual swap/set/read-at-the-same-point evidence, including unchanged size through
the actual masked traversal. These are contextual infrastructure for the selected
schedule endpoint, not filled aliases of standalone erased ECS projection laws or
a claim about all payload elements, general Type transactions or backend memory.

Run `python3 experiments/p-approved-owned-schedule/run.py`. Every checker/kernel
uses the existing five-second wrapper. `evidence.json` records exact frozen sources,
compiler/Base and imported proof closure, positive checker/kernel controls, false
fact rejection, and a kernel-negative control. The compiled-safe tick mutant adds
an implicit flush at the empty-list branch: the unchanged empty proof fails at
`empty_frame`; a separate independently active complete endpoint witness is false.
This is the **empty specialization's** gate, not the unfinished full endpoint gate.
The arbitrary unbalanced-tree and false-domain controls are separate from the
general proof. No dependency or timeout was increased.

One initial runner attempt hit the five-second kernel limit while the empty
case imported the entire pure schedule proof closure. That attempt did not pass.
The empty case now imports only its needed query-completeness dependencies and
constructs terminal observation directly; the full runner passes unchanged limits.
Earlier standalone passes are not substituted for this final runner evidence.

The second checkpoint adds actual returned-owner `RowsResult`/`WorldResult`
frames for every Reserve/Publish and mixed FIFO/Barrier input, plus a selected
Bump cell under its exact no-overflow premise. `allocation.bend` uses the actual
inline comparison/addition and separately proved caller guards; `commands.bend`
handles tag changes/despawn and new owned payload arrays; `bump.bend` connects the
actual read/add/set/read point to Nat successor on arbitrary arrays. Small controls
exercise reservation rejection, foreign publication, noncommuting FIFO actions and
an unbalanced-array Bump. These helpers also pass checker/kernel in the runner.

Remaining: member-wise Bump guard/row integration, composing the independently
delivered ModelSafe transport into actual owner-threaded schedule induction, full
endpoint and its own complete-law controls/mutants. Existing arithmetic and pure Nat schedule
proofs are dependencies, not evidence that these residuals have been discharged.
No production owner API, allocator/root policy, full-array preservation, readers,
transaction rollback, performance or #18 completion is claimed.
