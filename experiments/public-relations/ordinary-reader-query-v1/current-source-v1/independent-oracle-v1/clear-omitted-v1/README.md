# Current-source clear-omitted replacement counter

`clear_omitted_model.py` adapts the existing finite clear-omitted control model
to the current `replacement-unrelate` source and current failure-reader
identity. Before rebinding, it verifies that the old model still reproduces
both pinned historical outputs. It then verifies all 37 current source pins,
the reached callback and its exact one-site substitution, and the unchanged
fixture/consumer execution path.

The callback is `operations.bend:19`, in `clear_live`:

```text
case P.Writable{_,_,Cap.Request{clear}}:clear(owner,source)
```

The counter substitutes the reached historical mutation:

```text
case P.Writable{_,_,Cap.Request{_}}:(owner,A.Queued{})
```

The current replacement consumer calls `O.Clear{W.Handle{1,2}}` twice through
`writer` → `P.invoke_write` → `clear_body` → `clear_live`. The synthetic
mutant keeps the returned owner and queued status while omitting the supplied
clear callback, so the relation survives those calls. No source file is
modified to create the counter.

The source-derived current counter is 14,728 bytes with SHA-256
`fc31c658b18455c16d6a755cd36396a5e02e676596e43c125be6547c73430a87`.
`python3 clear_omitted_selftest.py` verifies the old model/golden pair, current
source and mutation joins, current reader-ID fields, stored raw/gzip bytes,
and distinction from the current replacement baseline.

This is a finite source-model counter oracle only. It does not claim a current
runtime mutation kill, a SystemFailure mutation result, universal proof, or
issue-level acceptance. No compiler, Node, backend, or candidate output was
used.
