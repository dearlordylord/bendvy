# Independent ordinary owned-event oracle

`derive.py` models the complete public `main.bend` trace from the immutable producer source at commit `bd57fde16fdad1bf52c0fec04d2f2f0787961859`. It emits the exact UTF-8 stdout in `expected.stdout`; `expected.stdout.gz` is the deterministic gzip copy. `SOURCE-BASIS.json` records the 27-file Bend source inventory, all 29 source pins, the producer freeze hash, Base and `IO.print` implementations, and the C/JS WorldIO namespace sidecars.

The source main performs two `WorldIO.create` calls for each schema, in this order: Workshop primary and foreign worlds, then Garden primary and foreign worlds. Both namespace allocators begin at 1, so the four worlds use namespaces 1 through 4. The scenario records an initial snapshot and all 15 actions for each schema, for 32 full snapshots total. `main.printed` places `Garden\n` directly after the final Workshop snapshot; `IO.print` appends exactly one final LF.

The modeled action path is the literal sequence in `scenario.bend`: fast read, slow read, successful two-payload publish, failed slow read, slow retry, aborted two-payload publish, successful next publish, frame, fast read, skip, two frames, foreign-world publish attempt, and two drains. The model keeps World registration/cursor data separate from event reader positions and ticks. It follows `Ev.run_position`'s one-tick read attempts, `Ev.with_world`'s one-tick publication attempts, the failure reconciliation that restores the prior reader cursor while retaining returned Args, frame boundary/capacity trimming, and log retirement. The failure returns the first payload projection and scratch update but leaves the slow reader cursor unchanged for retry.

The formatter is derived from `observe.bend` plus the pinned Bend Base and print effects. In particular, `payload_rows` and `rows` use recursive `"[]"` base cases with `";"` separators, so nonempty payload and row strings end in `;[]`; these are source literals, not normalized list syntax. Base `List.show` fields use comma-space separators. The outer Workshop/Garden composition has no extra separator beyond the literal `Garden\n` and the terminal LF emitted by `IO.print`.

To regenerate or verify the retained bytes, run:

```sh
python3 experiments/public-owned-events/ordinary-v1/oracle/derive.py
python3 experiments/public-owned-events/ordinary-v1/oracle/derive.py --selftest
```

This is a finite source-derived oracle for this one scenario and its two schema instantiations. No Node, Native, Bend consumer execution, generated artifact, or runtime stdout was consulted when deriving it. It does not assert broader schema generality or a memory/performance property.
