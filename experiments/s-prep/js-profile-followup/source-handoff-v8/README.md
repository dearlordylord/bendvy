# Fresh source-handoff producer and JavaScript enrollment

This package builds and enrolls the new v8 handoff closure, without changing Bend source, compiler, references, dependencies or the existing recipes. The frozen source is `/tmp/bendvy-slot-host-handoff-v8-coherent`, closure `4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235`. Only query, held-adapter and measurement differ from the original Slot Host source. The source author's minimal owning `Array.size >= capacity` guard precedes evacuation and delegates to the original path on failure. Its balanced-layout premise has separate executable backend canaries; no universal runtime refinement is claimed here.

`build.py` preserves the original full64 entry and fresh-initialization suffix, adapting only absolute imports and the frozen measurement prefix. It validates the coherent 29-file overlay/cache manifests. Before executing commands it snapshots the installed Bend executable, Base/effects, Clang wrapper/binary/resources and resolved ELF libraries. Clang `-M` additionally binds transitive C includes before compilation. Tool and include bytes are checked afterward. The installed compiler is embedded in the pinned Bend executable; this does not claim a separate installed TypeScript compiler source was consumed.

Run from this folder, using fresh absent output directories:

```sh
python3 build.py --execute --schema Motion --overlay /tmp/bendvy-slot-host-handoff-v8-coherent --output /tmp/bendvy-source-handoff-motion-build-v8
python3 build.py --execute --schema Health --overlay /tmp/bendvy-slot-host-handoff-v8-coherent --output /tmp/bendvy-source-handoff-health-build-v8
taskset -c 7 node --expose-internals pipeline/enroll.cjs /tmp/bendvy-slot-host-handoff-v8-coherent 4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235 /tmp/bendvy-source-handoff-motion-build-v8 /tmp/bendvy-source-handoff-health-build-v8
python3 pipeline/derive-normal.py --cpu 7 --source-root /tmp/bendvy-slot-host-handoff-v8-coherent --output /tmp/bendvy-source-handoff-generated-v8
python3 verify-normal.py
```

Build commands use CPU7: version/guide5, executable check15, C/JS emission30, Clang120. Runtime validators and diagnostic children use five seconds; default proof allowance remains five seconds. `build.py` without `--execute` prepares sources and a plan only. It never installs a toolchain.

The row, Data-token-pool and direct-Tuple safety recipes are byte-identical copies of the existing first-stage recipes. New exact source, producer-body, input and intermediate catalogs admit these programs. The normal catalogs remain immutable while lifecycle fixtures use a separate `fixtures-pipeline` folder. Old selective-Fold and positioned-swap recipes are not admitted: new drain calls introduce another taken consumer, and the old live boundary is no longer the normal ingress.

Fresh finite observations passed:

- Both schemas, raw JS and Native, and transformed JS: all 65 complete worlds equal fresh TS.
- Both schema normal diagnostic routes: 4,160 handoff/ready/drain calls and 1,064,960 getter, ledger, setter, setledger, invoke, taken and returned calls each.
- Eight actual retained lifecycle subjects, cached/raw × one/two rows × two schemas: 64 independent literal pre/post success/failure records. Counters are scoped inside the new handoff entry; retained Main and Ledger Data views are consumed after writes.
- Six live derived-receiver mutations omitting cached Main, cached Ledger or true-old capture were detected with positive execution counters.
- Sixteen helper records cover owning arrays of lengths 1/2/4/8, frozen retained views, repeated writes and pending inverse pairs. Row structural checks24 and Tuple order/exception/refusal checks34 passed.
- Nine-world expression counts fell from 6,160,448 to 4,455,488 for Motion and 5,900,864 to 4,195,904 for Health. These are executed construction-expression counts, not physical allocation or elapsed improvements.

Exact paths and SHA bindings are recorded in `status.json`; full producer/layer joins are checked by `verify-normal.py`. Broader lifecycle, authority and source mutations belong to independently recorded source controls. Old 576-controller receipts, full22, universal refinement and performance acceptance remain outside this package. Comparative clocks are root-owned; the canonical 20/20 allowance is not reset.

The deficient initial v8 metadata is retained as a read-only refusal: its source bytes match the coherent closure, but embedded/standalone and specialized cache maps did not. The source author repaired metadata in a fresh directory. This package does not overwrite v7 producers, catalogs or evidence. The fused generic owning row constructor replaces the previous Row-plus-List transport while retaining arbitrary affine Main payloads. Source recovery/order/authority controls and independent Native allocation counts belong to separate packages.
