# S-PERF independent Spec review

Reviewed `git diff a976667...1525208` and its commit list against live GitHub
#20, [the ticket](../tickets/19-integrated-performance-redesign.md) and
[SPEC](../SPEC.md). This reviewer authored no candidate implementation.
Bend LDD/installed guide were read. Source/evidence inspection, candidate
manifest hash checks and independent decoding of all twelve Readers gzip
artifacts were performed; heavy runtimes were not duplicated.

**Verdict: the bounded negative experiment is deliverable under clause 7;
production adoption and product performance remain rejected. No blocking
implementation defect or scope creep found.**

The bounded direct-ID mapping, separate affine Type columns, returned owners,
declared callback seam, FIFO preflight and joined rollback/readers match the
reviewed design. Main/E11/access/ownership and compiling mutation evidence cover
the specified finite cases. Actual Readers diagnostics preserve the full public
trace, expose retained entries after empty delivery and distinguish running from
stored readers. Quiet FailedTxn retains actual full-field/effect tuples and
forces their common ordered fold inside timing, with lossless validation after.

Three partial requirements remain recorded, rather than counted as passes:

1. Clause 6: “If timer quantization is material, repin the same longer work/batch
   on all backends.” Short Native Dense/Sparse, Readers64 and Lifecycle64 results
   remain resolution-limited. [#21](../tickets/20-indexed-performance-follow-up.md)
   requires shared longer batches, full validation and seven rotations before
   comparison uncertainty can meet an approved margin.
2. Clause 5: “Setup, warmup and final serialization stay outside the inner
   interval.” Quiet FailedTxn warmup runs in separate children, so it does not
   warm measured JS/TS VMs. Its ratios describe fresh-child execution; the report
   retains a shared same-process warmup/fresh-measured-world return gate.
3. Clauses 5–6 require every workload/size outcome and actual occupancy.
   Larger Readers and Motion1024 FailedTxn repetition deadlines remain failed;
   active-workload transaction staging/inverse/mark peaks remain unavailable.
   Concrete equivalent-work and owner-preserving hook follow-ups retain those
   return gates; finite fixtures and successful retries erase no failures.

Clause 7 explicitly allows a negative with “failed capability, reason, concrete
follow-up and return condition recorded.” The completion report and blocked #21
provide these. JS regressions and inconsistent Native speedups defeat adoption;
no numerical threshold, new law, dependency or universal refinement is approved.
Follow-up publication does not make its prerequisites complete or unblock the
simulation/application integration.
