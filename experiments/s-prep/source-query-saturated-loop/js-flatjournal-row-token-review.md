# Read-only review: flat-journal row reuse and token pool

Reviewed the current root-owned `experiments/s-prep/js-flatjournal-row-reuse` recipes and actual Motion v2 output. No diagnostic code or oracle was edited and no heavy process was run. No concrete incorrect rewrite was identified for the exact admitted emitted inputs. This is a closed-program diagnostic review, not a compiler legality or adoption claim.

## Structural findings

The getter rewrite retains all seven original owner projection reads in their original prelude, returns the original affine owner and retains Tuple/Found/Some and immutable cached-view payloads. It removes only the fresh private row-owner constructor. The inspected emitted getter has seven explicit projections before return ([actual output](/tmp/bendvy-fourhour-flatrow-tokenpool-motion-v2.js:4656)).

The setter requires a direct saturated unique done caller. It appends the consumed owner after the original arguments, preserves the done prelude, evaluates all seven original result expressions in original field order into new const binders, and only then writes changed owner slots. Same-slot store elision traces a done parameter through the actual saturated caller argument and pure local projection bindings. New cached views, undo and marks remain fresh expressions, not mutated Data ([row recipe](/workspace/formal-proofs/bendvy/experiments/s-prep/js-flatjournal-row-reuse/rewrite.cjs:24)).

The token pool checks the exact nullary Data source declarations and actual 29-source facts, qualified tags, reserved namespace and closed receiver forwarding. It refuses token writes/identity/unknown escape/capture and keeps unproved sites unpooled. Object.freeze introduces shared constants only for those proved read-only token flows ([token recipe](/workspace/formal-proofs/bendvy/experiments/s-prep/js-flatjournal-row-reuse/token-pool/rewrite.cjs:8)). Pooling does not share raw affine owners or cached record snapshots.

## Recipe and evidence boundaries

Exact JS input hashes and current source file hashes constrain both passes. Full65 orchestration additionally verifies final output, recipe and catalog hashes, intermediate row output/receipt hash, row baseline input and actual source hashes ([chain validation](/workspace/formal-proofs/bendvy/experiments/s-prep/js-flatjournal-row-reuse/full65.py:13)). The token rewrite itself records rather than validates `rowRecipeSHA256`; complete lineage depends on that orchestration, not calling the token recipe alone. This is a packaging boundary, not an observed semantic failure.

The row AST checks are local: they do not independently prove every receiver is a plain generated object, exclusive ownership, absence of FFI escape or whole-program alias freedom. That confinement depends on the exact admitted generated program and source affine owner route. The source/input catalog must remain audited; adding a synthetic catalog entry is not justified merely because local structural guards accept it. Seven structural refusals are targeted shape controls, not a complete alias/getter/proxy refusal theorem ([guards](/workspace/formal-proofs/bendvy/experiments/s-prep/js-flatjournal-row-reuse/guard-controls.cjs:7)).

The getter local guard permits pure inline projection paths; replacing its fresh owner could omit repeat inline projection evaluations on a newly admitted input. Actual inspected getters already bind all projections in the retained prelude and their result fields are identifiers, so this is not an observed defect in the pinned v2 program. A generalized catalog requires preserving those reads or tightening this precondition.

Root reports fresh controller matrices, retained-view witnesses and refusal controls. This reviewer inspected code and provenance rather than rerunning or transferring those results as new review gates. Raw ratios around 1.0 Motion/1.1 Health remain unqualified and do not establish the mandatory performance target. No source callback/authority algorithm was replaced by either diagnostic.
