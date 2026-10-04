# Scoped checker repair for #18

Coordinator decision, 2026-10-04: use the reviewed recursive-rigid source checker
locally for #18 proof checks. This is a reversible tooling repair within the user's
instruction to continue implementation, using existing Node and read-only pinned
source. It installs no compiler, adds no dependency and edits no reference checkout.
It does not claim new user law approval or production compiler adoption.

The installed 2.0.34 checker and untouched pinned 2.0.35 source both reproduce
the exact source-unfolding stack failure. The patch reuses the complete existing
rigid comparison before recursive normalization; mode, depth, arguments, labels
and quantities retain their original checks. Patched source remains separately
identified as 2.0.35 at `a950fd683c0d76f09794078e6174fe98a1492876`.

Authority and scope:

- The copied Base is byte-identical to installed 2.0.34 Base.
- Every accepted proof also passes the unchanged installed 2.0.34 BendTT kernel.
- All checking/kernel invocations retain a hard five-second process-group limit.
- Frozen source/patch/runner/kernel/fixture hashes, intended negative diagnostics,
  EQ/LE/binder/depth/label controls and a forced-false-kernel control are enforced.
- [Spec review](owned-checker-candidate-spec.md) recommends this scoped use;
  [Standards review](owned-checker-candidate-standards.md) resolves runner findings.
- [Diagnostic](../../experiments/p-owned-checker-diagnostic/README.md) retains
  causal baseline failures and version/alignment limits.

Broader compiler validation and production adoption remain separate. The exact
owned theorem, seven-endpoint aggregate and issue acceptance still require their
own proof/mutation/review evidence. This decision changes no law, domain, quantity,
runtime, payload scope, allocator policy or performance threshold.
