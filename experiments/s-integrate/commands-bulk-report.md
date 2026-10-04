# S-INTEGRATE command application prerequisite

`commands.apply` now traverses actual affine rows with a reversed prefix and a
remaining suffix. Nondecreasing command targets continue from the cursor; lower
targets rejoin and restart. Retained rows return in ascending logical-ID order.
Lifecycle records accumulate in reverse and reverse once at the barrier. Public
World, handle, reservation, queue and application signatures are unchanged.

The existing SI-CMD-FIFO implementation variant and domain were drafted in
`COMMANDS-BULK-LAWS-DRAFT.md`; the independent model rejected 609 perturbed
complete observations before implementation. No ECS proof was written.

Commands run from the repository root:

```sh
python3 experiments/s-integrate/commands-bulk-contract.py
python3 experiments/s-integrate/storage-stage-run.py
python3 experiments/s-integrate/commands-bulk-run.py
```

All passed. The original storage runner rechecked 153 output lines, eight actual
TS E0/E1 snapshots, seven expected static rejections and five compiling runtime
mutants. Its evidence now records the optimized command source hash.

The separate bulk runner supplies schema and count through runtime arguments.
For both schemas and counts 1, 17 and 65,537 it uses actual factory creation,
reservation-returned handles, queue wrappers and three explicit apply barriers:
spawn, remove Main, then despawn. It checks pending-only initial state; every
row's logical ID, marks, nominal Main/Aux four-slot arrays and metadata, Flag;
full Ledger and Mode; empty pending queues; each ordered lifecycle handle; and
final empty live storage. The remove phase retains and rereads all Aux owners.
The largest run checks 262,148 lifecycle records. Observations return the actual
owners before subsequent operations.

The mixed sequence 4,1,3,1,2,4,4,1,1,7 uses genuine issued handles and distinct
payloads. Both backends match the independent complete live-world and ordered
Change oracle, including Aux-only insertion, lower-ID reset, repeated overwrite,
remove/reinsert, stale no-op and despawn. Five additional mutants compile and are
detected on both backends: omitted lower-target reset, skipping equal targets,
reversed final events, lost Aux on Main removal, and reversed spawn event pair.

Recorded whole-fixture wall times, including process startup and all checks:

| Schema, 65,537 entities | Native | JavaScript |
| --- | ---: | ---: |
| Motion | 0.034 s | 0.685 s |
| Health | 0.029 s | 0.585 s |

Each checker and runtime invocation has a five-second limit. C/JS generation has
a separate 30-second limit and clang a 120-second limit. Exact source hashes,
outputs and individual timings are in `commands-bulk-evidence.json`.

These are single-run prerequisite measurements, not a TS-comparable benchmark,
a numerical threshold approval or production performance acceptance. The
traversal bound is linear in commands plus rows traversed for nondecreasing
batches; arbitrary alternating targets can remain quadratic. This does not
complete E11 public reader retention, universal refinement, exhaustion/reuse or
root-authority gates. The trusted fixture assumes valid issued unique spawn IDs,
sorted reachable rows and bounded arithmetic; it introduces no new adoption
policy or data-only component restriction.
