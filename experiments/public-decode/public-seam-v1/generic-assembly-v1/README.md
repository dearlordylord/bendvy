# Generic assembly source candidate (#46)

Experimental source preparation; not production promotion or issue closure.
`complete.bend` combines ordinary registered consumers and immediate recovery controls.

| Consumer | Schema | Component owner | Resource owner | Scenarios |
|---|---|---|---|---|
| public-fixture | Unit | second-owner.Owner (Raw + two affine arrays) | historical controls.Owner (Raw + affine array) | success, failure, no-match, Local.skip |
| first-public-fixture | first-owner.Schema | historical controls.Owner | second-owner.Owner | same four |
| recovery-fixture | Unit | second-owner.Owner | historical controls.Owner | interleaved inverses, equal-position LIFO, Pending, success, reservation/install/activation refusals |

Ordinary clauses derive grants, selection and registration access. The gameplay body
is abstract over H and reaches Cap.owned_request; it receives no World. Both nominal
schemas use the promoted ordinary-declaration/decode-data/persistence-declaration
cohort. Old Raw values cross an explicit detached Data conversion boundary.

One affine argument owner threads through selected rows. Failure discards row Data
observations and retains arguments/refusals/recovered packets in explicit app Local,
using approved Local recovery. Immediate receipts remain outside World, positioned
by the library ordinary undo count; equal positions unwind newest first. The fixture
interleaves resource replacement, spawn A, component replacement, spawn B, resource
replacement, then abort. Rollback restores payloads/stamps/liveness/resource while
preserving established monotonic clock, consumed IDs and grown capacities. See
src/ecs/component.bend, src/ecs/bundle-component-install.bend and
 docs/reports/relations-application-initial.md. Pending retains its recovery owner
and explicitly represents incomplete rollback.

Source5 CPU5 shared-lock checks pass for the combined entry and read-only positive.
Undeclared, read-only, cross-schema and duplicate-affine-owner bodies fail at the
actual capability assembly seam. Exact receipts/pins: source-checks.json and
source-closure.json. These are type/source checks, not mathematical proofs.

Remaining scope: the finite Ops shape and fixed application Local are experimental.
The generic body does not invoke deferred decode; prepared-success handling aborts
rather than claiming generic deferred delivery. Existing qualified 32+12 historical
consumers are unchanged. Coherent public library promotion, broader ordinary clause
assembly and generic deferred success delivery remain integration work. Activation
refusal is a trusted kernel control. Observations support ordinary Column explicitly;
other storage layouts report unsupported. No runtime/performance claim is made.
