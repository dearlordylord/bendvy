# Actual live-core component-state replay

`python3 experiments/public-component-state/run.py --output .artifacts/component-state-live-qualified-v1 --cpu 11` completed `PASS_FINITE_SLICE`: 87 commands. This fresh cohort tests actual live `src`, not the earlier staged World patch.

Receipt SHA256: `1219a8ef1bb3c0d5e3eaee56b1c8c577a695afbf3af00ed9f092973005bb4183`. All 61 named source hashes were verified unchanged at terminal, including World `a20b0f2363dab12b73109354ebddf5c9126d3e786031cf9232a0c68c5ffc3b5c` and string-equality `2f0f31d7ab0151d0619412b68cfd8304ae20905c147628e36d9dd2918cf27723`.

Observed coverage: 54 actual TS descriptor checkpoints; complete 62-row application across two schemas; three constructor, six foreign-world, five access, five raw-boundary and seven clock rows. Full normal observations match the fixed goldens and actual reference adapters. All eight intended access/ownership/schema/type negatives reject at their named locations. All five compiling mutants (diagnostic omission, access coalescing, write-status omission, move-status omission, wrong target) reach full-observation divergence on both JS and Native.

Checker/emission/Native compilation/runtime caps remain 5/30/120/5 seconds; Native uses one thread and GPU off. No timings were collected; no laws or proofs are approved by this finite replay. Profile and comparative observations remain the separately frozen earlier subjects. JS comparison goals remain unmet there; this receipt does not invent a performance acceptance gate or close #47.

Portable evidence retains every stdout/stderr log and compressed complete receipt, with exact inventory. Emitted artifacts and task-local binaries remain hash-bound by the receipt. The terminal source check covers the named consumed closure, not unrelated repository membership. Integrator owns regression, review and delivery.
