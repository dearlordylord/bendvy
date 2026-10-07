# Phase 2 source development status

This fixture is not yet backend- or performance-qualified. The immutable phase 1 receipt remains a finite boundary qualification; its historical source has not changed.

The current driver performs runtime input validation and both nominal worlds' registered setup before Begin. Its operation body preserves the original fifteen snapshots, eleven queries per snapshot, registered writer/failure/rollback/deferred/cleanup paths, and complete payload and graph projections. Population, hierarchy span and payload seed affect actual ECS operations. The retained initial snapshot comes from the initial observer's existing optional query, without an extra capture query.

The independent expected outputs for population64/seed0, population64/seed4294967295 and population256/seed0 each contain all thirty records. Their manifest reports expected operation counts; none is an observed consumer result.

Development diagnostic receipts are under the worktree's `.artifacts/relations-phase2-source-*` directories. The last three attempts archive every byte in the forty-one-file local import closure:

- `1791405705168278010`: affine count duplication, repaired with an explicit duplicated Data binder.
- `1791405714972266569`: IO.args returns an affine list, repaired to consume `List<&1,String>` directly.
- `1791405727495724004`: parser, types and affine binders reach the foreign boundary. Exit1 reports only the nine expected foreign/unsafe IO effect definitions. This is not proof PASS or runtime acceptance.

Whole-tree forcing and serialization use population-derived budgets and explicit incomplete results. Exhaustion does not produce a normal full JSON output. The bound, all input cases, actual emitted forcing order, same-artifact population/seed controls and backend completion remain unqualified. No timing or scaling claim is made.

The first actual complete-oracle development preflight is now successful: `.artifacts/relations-phase2-cheap-1791406184079972997/receipt.json`, frozen plan `5b6f85ea4e4951077bbf74fe87258aece0211d8dc2270045f5fed3c8084b935e`. TS and Bend's in-process emitted-JS IO consumer each completed population64/seed0 within the unchanged five-second command cap. Each produced all thirty exact independent expected records (stdout SHA `2be9ea3801409981ec799bee9a8aa712d974f2b29096336692a95ba818cccbd6`) and the exact Begin/completed-whole-walk controls. This is development seam evidence, not backend/proof/performance acceptance. A prior environment guard failure launched zero subjects and remains retained separately. The fresh child environment is private, hash-guarded and excluded from delivery.

Standalone JS now passed the focused finite three-input qualification under plan `d4aae3dafd8cd4f390f7ad4994fd0140fc46a87c3e061a3b8851c96ac1099461`: one emission, then the same generated artifact completed all thirty exact records for population64/seed0, population64/seed4294967295 and population256/seed0. Receipt `b31cab3865c1d3c136f23cc12d80e723e49f28a05c5b8b56fc6c7c5221ce9d26` retains four subjects, thirty-six execution guard probes and complete raw outputs. [JS-EFFECT-ORDER.md](JS-EFFECT-ORDER.md) records the actual emitted boundary review. Remaining cases, exhaustion falsifiers, Native and timings are still unqualified.
