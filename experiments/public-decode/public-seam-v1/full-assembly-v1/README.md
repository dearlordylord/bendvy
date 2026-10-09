# Registered Decode assembly — experimental, source-only

This is an application-owned assembly candidate for #46, not public core promotion or backend qualification. No new ownership, cleanup or failure policy is established. Rust Bevy architecture is first authority, Bend affine/runtime constraints second, pinned bevy-ts feature inventory third.

## Reached route

`spine.bend` preserves all original 32 world operations, the genuine Factory-threaded foreign-world case and all twelve selector extensions. The existing List-spine transport is reused unchanged apart from imports. Ten world-bearing extension cases provision a typed resource registration; the two detached-load cases remain detached.

The 32-operation route is:

`main.provisioned → Local.register → snapshot → Local.run → Public.provide/invoke → opaque H gameplay body → OwnedRequest.run → retained operation/codec → App.request_with_completion → retained Decl.validate → actual Batch or resource mutation`.

`Public.Args`/`Public.Output` contain no raw World. `Public.invoke` accepts arbitrary affine argument/output types; the supplied request uses the existing arbitrary-Type packet provider. Runtime access is granted by the actual owned operation, not access strings. Registration derives its access names from the same component/resource identity. Registration and invocation refusal remain distinct from operation validation/entity refusal.

The ten world-bearing selector extensions use the existing selector and precedence contract with a `Typed.Context` retaining a real Local instance. Accepted owners reach `Typed.request → Local.run → App.resource_typed → Cap.invoke_owned → declared resource grant`. Plain/Transient do not acquire a constructed validator. Constructor-result selection remains before publication; detached-load selection is unchanged.

## Ownership and visibility

- Deferred packets retain `Maybe<P>` exactly as existing component/bundle refusal shapes do. No affine payload is reconstructed in a physical None branch.
- Successful Batch finish queues prepared delivery at its authored command position. Original before/after/barrier snapshots retain the entire physical world; insertion and spawn are explicitly deferred in this candidate.
- Successful replacement stores the previous owner in explicit application `Mail.retired`. Late rejection stores original packets/errors in `Mail.returned/errors` through the existing Delivery recovery callback. This is an application choice, not the unresolved #41 global activation/recovery default.
- Actual resource grant journals only the declared `Mail.value`; unrelated retained/recovery owners remain intact. It follows `Resource.tx_replace`/`restore`: old owner lives in undo; rollback restores it and drops the displaced replacement. There is no separate return of the restored owner.
- `failure-controls.bend` selects existing `T.Failure` through the same registration and provider. Batch rollback returns every prepared packet; application Local retains output/packets according to approved #36. No output is inserted into `Sys.Failed`, and no #50/#53 default is chosen.
- Complete observations include all world metadata, slots/stamps/liveness, original/canonical payloads, sentinel leaves, pending count, Mail owners/errors, and registered Local identity/access/declaration/completion and every recovery output/packet. Consumer observations dispose projected owners only after recording them. Typed Local is Unit; its complete metadata is already in world registrations.

## Controls and evidence

`evidence/source-results.json` records explicit preserved compiler 2.0.35, CPU5, shared heavy lock, five-second child cap and `--check-only`. Candidate List spine, failure controls and both full consumer mutants source-check. Negative files reject at the actual opaque-body operation types: undeclared grant, read-only grant, cross-schema arguments, and affine argument duplication. These are compiler rejection controls, not executed semantic controls or a proof that all registration combinations are provisioned.

Two full source-current mutant consumers are supplied:

| Mutant | Reached change | Expected whole-model disagreement |
| --- | --- | --- |
| `mutants/skip-validation/spine.bend` | Replaces real retained validation in deferred command and constructed resource admission with projected raw acceptance | Invalid arrays/structs become admitted; canonicalization disappears |
| `mutants/partial-write/spine.bend` | Corrupts the physical resource in `Public.request` before retained validation | Rejected operations change the complete resource snapshot |

Both preserve the entire consumer and observation graph. They have not been executed or killed yet. Raw failed development source checks remain diagnostic evidence, not passing receipts.

## Remaining gaps and exact next step

| Capability | Current source | Remaining owning scope |
| --- | --- | --- |
| Declared owned validation/mutation | Reached registered application assembly | #46 independent source-current whole oracle + complete interpreter/JS/Native acceptance |
| Successful deferred insertion/spawn | Existing Batch/Delivery with explicit application recovery | #46 runtime qualification; #41 global activation ownership remains open |
| Failure rollback/owner recovery | Existing Batch + explicit Local, full failure control source | #46 executable semantic checks; no new #50 default |
| General public declaration compiler | Concrete application registration plus generic opaque request body; trusted adapters still select closed providers | #46 shared-core integration by integrator after review/#28; no generic promotion claim |
| Immediate spawn surface | Not supplied: this assembly selects deferred spawn | #46 explicit remaining API/qualification gap |
| Combined read/query/owned-write declarations | Existing query declarations not unified here | #46 general capability assembly integration gap |

Before any heavy child: independently author a whole oracle for this exact new observation tree (including registration, deferred queue, Mail and Local). Keep the prior complete oracle unchanged; this is different declared visibility, not byte rebinding. Reuse the existing `adoption-v1/qualification-v1/spine-report-v1/development-run.py` collector and `transport.py`, prepare exact complete candidate plus two mutant source closures and per-backend plans, obtain parent admission, then run serialized under the shared lock. No new collector or heavy child has been launched by this candidate.
