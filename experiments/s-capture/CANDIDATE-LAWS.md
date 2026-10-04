# Prospective system-state/restoration obligations — unapproved

This is a research hypothesis sheet, not an approved ECS law package or proof.
The explicit-owner prototype and first TS checkpoints preceded this sheet;
the hypotheses were recorded before completing the mutation suite. #12 owns the
connected replacement-law proposal. Do not infer approval from this experiment.

1. **Repeatability and isolation.** Each successful invocation of
   `local.invoke : Local -> Local & U32` advances its own admissible counter by
   one and returns the sole owner. An invocation of B preserves A's counter and
   vice versa. Under this bounded counter domain, observing the returned Local
   yields the returned count. A condition skip calls neither factory nor body.
   Why: a once-only capture or shared counter cannot represent independently
   persistent system instances. Mutants: reset the increment result to1;
   route B through A's owned counter instead of B's. Finite witnesses include
   A=1/B=2 at failed invocation, A=1/B=3 on retry and A=2/B=4 later.

2. **Reversible owned mutation.** For the supported fixed-slot numeric-write
   algebra, `core.finish` of a typed failure restores the exact pre-invocation
   payload, retains earlier committed publications and drops only this
   invocation's staged publications. `finish` of success publishes them once
   and retains the writes. No Type payload/Array is cloned. Independent finite
   reference: TS failure after11→21→31 leaves11; successful retry leaves31.
   Why: retaining only the last inverse or applying inverses in forward order
   loses the earlier committed value. Mutants: omit unwind; reverse journal.
   Arbitrary callbacks that consume/discard an affine owner are **not covered**.

3. **Failed reader and nested propagation.** Failure preserves the B reader's
   saved position and fails its parent with B/code7 without executing Tail.
   A subsequent retry sees message1 again; success advances the saved position
   to its entry boundary and leaves own message9 visible next invocation.
   Registered skip discards the unread7 backlog while leaving capture6 absent
   until the next actual invocation. Why: advancing on failure prevents retry
   and running the parent tail violates nested failure. Mutant: advance reader
   during failed finish. General marks/allocation/lifecycle cursors belong to
   S-INTEGRATE; this count-position helper is not that integrated runtime.

4. **Affine closure boundaries.** `closure.make : Local -> Unit -> Local & U32`
   consumes one captured owner; invoking the result once returns it. Recreating
   a new closure from that returned owner is repeatable. Calling one closure
   twice or duplicating Type payload as a rollback snapshot must be rejected.
   A destructive transfer cannot leave a reusable alias for subsequent abort.
   These are intended checker controls, not runtime mutant kills or ECS proofs.

To become general laws, state counter/U32 bounds, reachable owner/world states,
token authority, reader registration/retention and the exact operation mapping;
then falsify exact statements, obtain specific approval and prove them separately.
Finite Native/JS/TS agreement does not prove backend soundness, universal
confinement or runtime refinement. A proposed ECS-owned Local's identity,
lifetime, failure rollback and provisioning policy remain explicit decisions.
