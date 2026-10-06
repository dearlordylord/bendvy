# Independent public capability controls

These independently authored consumers import actual `src/ecs/capabilities.bend`
and `compose.bend`; no replacement ECS modules or fabricated diagnostics are used.
The runner stages a read-only source closure and the exact fixture bytes, wraps
each checker invocation with timeout5, rejects timeouts, and records every ECS
module hash, fixture hash, runner hash, manifest hash and compiler version.

```sh
python3 experiments/query-composition/run-controls.py --output /tmp/query-public-controls
# Before integration, replay against the independently authored source worktree:
python3 experiments/query-composition/run-controls.py --source-root /tmp/bendvy-query-compose-core --output /tmp/query-public-controls
```

The suite contains eight independent controls and two integrator-added controls for runtime
closure rejection and correctly constructed detached Frame; integrated evidence is recorded separately. Positive five-field arbitrary Ops shape actually
specializes and invokes `Cap.invoke`. Two writes and three read aliases operate
through one opaque affine context containing an actual Array payload. Runtime
output `[70,71,71,72,73]` is read B after write A, read R after write B, then all
three final array elements. This is a public capability mechanism observation,
not a full World query/transaction/lifecycle acceptance test; Workshop provides
the independently authored integrated application. Positive-selection observes
optional absence succeeds, required absence fails, present succeeds, absent
succeeds only when missing. Positive-family checks the actual typed Family binding.

Negative controls require exit1 plus real `expected`/`observed` diagnostics:

- Writes-through-read: `Cap.set` expects Write and receives Read; optional reads
  have this same authority surface and cannot acquire a setter from optionality.
- Duplicate context: actual opaque H is consumed twice, while repeated capability
  aliases in the positive fixture remain permitted.
- Undeclared resource operation: direct public `Q.resource_set` requires concrete
  Frame; a gameplay callback receives abstract H. Filter membership never supplies
  this missing authority.
- Reconstruction: actual public `Q.Frame` constructor cannot inhabit universally
  abstract gameplay H, even when the caller supplies a separate concrete World.
- Runtime capability: an instantiated `Cap.read` cannot accept a runtime affine
  operation record as a closed template argument. The compiling positives use
  closed operation records.
- Cross-schema Family: binding a foreign typed Family/lens bundle through
  `Q.read_family` for S1 rejects the S2 column projection at that public seam.
  The positive uses exactly the same arguments with S2 consistently. This does
  not claim a different error location at the final Family argument.

An initial uninstantiated five-field callback checked but its eventual template
specialization exposed a runtime-variable/comptime-argument misuse. The final
fixture uses closed field projections and actually invokes the public executor;
only this executed positive establishes the observation. Initial source import
also encountered the author's temporary `Cap.invoke` output-Data mismatch; source
was repaired by its owner before these final checks. No proofs, laws,
dependencies, compiler/kernel edits, performance or universal refinement claims
are introduced. Root must replay these receipts against the integrated closure.
