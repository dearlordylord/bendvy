# Adjacent private Main/Ledger journal pairing feasibility

Implemented bounded mechanism experiment; adoption and complete capability gates remain OPEN. Baseline is joined8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26. Public callbacks, public Tx/Handle authority and arbitrary affine Type components remain constraints. No proof, universal law, speed result or full gate is claimed.

## Actual baseline

`held-adapter.bend` private Main `prototype_flatrows_*_set_fused_done` prepends FlatMain{namespace,id,true_old,undo} and a mark immediately. Private Ledger `*_setledger_fused_done` prepends FlatLedger{true_old,undo}. The authored callback invokes Main then Ledger; thus its head is Ledger(oldL,Main(ns,id,oldM,tail)). Generic callbacks may invoke setters in any order or not invoke them. Incoming legacy journals are packed independently. Current transaction.bend:146–150 unpack preserves head order; unwind:168–172 applies the head first. The private row-return flush boundary is held-adapter.bend:429/476; generic fallback is between rows.

## Proposed private representation

Add scalar `pending_main`, `pending_namespace`, `pending_id`, `pending_old` fields to the private row owner. Keep its generic raw/view/ledger fields affine and its selected Handle unchanged. Do not store a Main journal node at the first Main write. Keep the mark append at its original setter location.

- Main setter: flush an earlier pending Main to the existing tail, then remember the current true-old Main scalar and bound namespace/id. This preserves repeated writes separately.
- Ledger setter: when pending, emit a single private `LedgerThenMain{namespace,id,main_old,ledger_old,tail}` and clear pending. Otherwise emit ordinary Ledger. Consecutive Ledger writes remain distinct.
- Read providers: retain pending scalars unchanged. Getter behavior and retained views stay unchanged.
- Row return: flush a pending Main-only write before exporting undo. No pending state crosses the row or generic fallback boundary.
- Pair unpack: materialize `LedgerInverse{ledger_old} <> MainInverse{bound_handle,main_old} <> unpack(tail)`.
- Pair unwind: restore Ledger first, then the bound Main, then recurse on tail. Pairing does not delete failed writes, marks, commands or pings.

A Main-only write, absent-Ledger row, repeated Main sequence, Ledger→Main, Main→Ledger→Main, incoming legacy journals and failure remain representable. Concrete Handle reconstruction uses only the existing checked schema/world namespace/id. No abstract H constructor is introduced. Opaque client access remains through the same supplied providers; original callback text is unchanged.

## Expected mechanism, not measured benefit

Actual Native flat-row/fold owners are already unboxed; pending scalars may remain parameters. Avoiding allocation must defer Main construction. Allocating Main immediately and later merging its head cannot remove that request. A combined node carries five fields; existing Main has four and Ledger two. Native class rounding may make requested words unchanged even if one node/redirect per pair disappears. Wider parameter transport may also add costs. No improvement can be inferred before current-source Native/JS counters and fresh65 fields.

## Required first experiment

Use a separate coherent29 overlay changing only private owner/providers and private inverse family consumers. Preserve original public definitions, authored callback hashes, initializer aliases and cache/source maps. First build/check limits15/30/120/5; exact both-schema fields and actual counters before any expanded gates. Literal finite mechanism cases must include Main-only, repeated Main, repeated Ledger, both orders, cross-row boundary and legacy tail. Later reached controls must cover true-old saturated writes, arbitrary owned arrays, generic fallback/repack/finish and rollback order. Compiling mutants must lose pending Main or reverse pair restoration and fail the independent oracle. Do not transfer v4 or joined gates.

The source implementation and finite receipts below establish this local mechanism; they do not establish a completed optimization.

## Separate v1 actual source first stage

The bounded candidate is now materialized by derive.py from the exact pinned joined29 input, preserving unchanged public callback/provider definitions. New cloned opaque private row-provider families carry Type PrototypePendingUndo. Existing private row entry/return redirects to those families; return flushes pending Main. A new private FlatPair constructor has exact unpack and unwind consumers. Generic fallback remains unchanged after flush. Candidate /tmp/bendvy-paired-journal-v1; only held-adapter/transaction source bytes differ.

Actual Motion full64 checker15, C emission30 and approved Clang19 compile120 PASS. Fresh instrumented Native65 full-world equality/current29/original C before-after PASS. Requests20,317,127 (−2,097,152 vsjoined parent), RFC9,527,614 (−1,048,576), requested words57,236,495 (+1,048,576). Thus one pair removes2requests/update including one redirect but adds1requestedword/update through class rounding. Executed FlatPair count1,048,576 replaces the previous1,048,576 Main +1,048,576 Ledger constructors. This is a mechanism result, not speed acceptance. Health, arbitrary nonpaired callback routes, actual rollback/fallback, authority and compiling-mutant gates remain OPEN. The mechanism.bend fixture is still under bounded development; its checker success alone is not a runtime gate. No composition with identity query has occurred.

Finite mechanism controls now PASS on JS and Native: seven literal journal/order cases,14 records/backend, actual pending helpers→flush→unpack plus private unwind vs original generic unwind. Cases include no writes, Main-only, Main→Ledger, repeated Main, repeated Ledger, Ledger→Main and Main→Ledger→Main, all with incoming legacy Ledger tail. Affine Array owner survives restore callbacks. Logs make restoration order observable even where final scalar state commutes. Two compiling actual-source mutants—lost pending Main at flush and reversed pair restoration—are detected by the independent literal oracle on both backends. Limits15/30/120/5 unchanged. This remains a helper-level finite gate; actual private row setters/return, full Tx rollback/fallback, marks/commands/pings and authority gates remain OPEN. Initial fixture diagnostics required affine scalar duplication inside restore bodies and duplicated report label; they were repaired without altering provider arrow types or compiler.

## Current v2 source and reached finite gates

v2 closure a72494c68499f96732c88c9e65a14a00443c972fd82c7de593aa632bb95fcc82 has exactly the same29 Bend bytes as v1. derive.py now reconciles standalone/embedded cache digests and pins the complete baseline input map; this repairs metadata, not source semantics. Health full64 Native+JS and ordinary Motion Native+JS each pass fresh65 fields. Health requests20,317,127/RFC9,527,614/words61,430,799; each schema saves2 requests including1RFC/update but adds1requestedword/update. Health initial validator wrongly read the reference envelope rather than each world's warmup/sample record; its KeyError receipt is retained, and finish-build.py verifies archived JS rows against matching fresh TS records then runs Native freshly. No Bend rebuild or silent overwrite followed that diagnostic.

Fresh protected actual Tx cached/raw controls pass both schemas/backends, including live-noop true-old journal/mark suppression. Actual nonidentity rank2 generic callback through fallback, repack and private finish passes, with a separate concrete transport transformer observing selected/undo/commands/pings/marks. The compiling actual generic-conversion mutant dropping returned selected/journal/command/ping/mark state is detected on both backends. Generic affine Main/Ledger Array owners pass and illegal Data cloning rejects. Actual paired row retained snapshot controls pass raw foreign/local partitions both schemas/backends. Point controls materialize Pair into legacy before observation/repack: these receipts are not evidence of every fully flat measured finish route.

Open gates include dedicated private authority/access negatives, further reached nonpair/repeated rank2 setter patterns, direct fully flat actual Tx rollback and complete capability gate. Current helper laws are only finite executable witnesses, not approved ECS proofs. No gate is inherited by query+pair or packed-slot composition.
