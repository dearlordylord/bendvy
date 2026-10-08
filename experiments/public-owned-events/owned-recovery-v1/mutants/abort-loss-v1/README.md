# Reached abort-loss development falsifier

The staged `staging.bend` differs from the baseline in exactly one expression:
abort wraps its FIFO `List.reverse` in `List.tail`, dropping the oldest available
staged owner. Production staging is unchanged. Staged controls/main are identical
to baseline; actual main consumes this mutated abort through both abort and
immediate-refusal terminal paths. Commit remains complete.

The unchanged full baseline oracle is copied byte-for-byte. An independent
pre-run counterfactual expectation states the exact resulting observation:
commit retains both payloads, abort loses first[11,12] and retains the entire
second[21,22,23,24], refusal loses staged first while returning incoming second
completely. Actual JS output matches this whole counterfactual and differs from
the unchanged baseline oracle. This is a reached compiling semantic mutation,
not a comparator-only edited output.

Guide/source5 completed; source check PASS. Actual emit30/Node5 CPU5 finished
exit0 under the existing child lock and guarded direct development runner;
runtime stderr empty. Full stdout SHA256
`da8dd9fada1e1c963ef7a0166e6d23bd2afbd43e3a3994488d68e6d61f960137`.
Raw/plan/receipt retained in evidence/js-1. The runner narrowly reuses the same
baseline development mechanism with unchanged-oracle rejection plus whole
counterfactual comparison; no new collector framework or dependencies.

Run `python3 experiments/public-owned-events/owned-recovery-v1/mutants/abort-loss-v1/verify.py`
for a no-child exact one-expression delta, staged binding, source/oracle/raw join.
No Native mutant, tool-resolver/portable delivery, proof, World integration or
#53 closure is claimed. Baseline JS/Native and original LF-failure history remain
unchanged. Reader/fan-out, World/rollback and performance gates remain due.
