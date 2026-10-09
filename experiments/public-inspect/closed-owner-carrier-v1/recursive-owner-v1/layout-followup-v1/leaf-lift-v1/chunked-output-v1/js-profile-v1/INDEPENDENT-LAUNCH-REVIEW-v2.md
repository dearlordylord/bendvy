# Signed-delta successor admission

Scoped admission PASS for successor preparation `91bc6c60ad4e30bc12b572caec06e23aab585966`. Exact four profile02 plan hashes:

- before CPU: `343def081319f2d7b0f53712cf3ecc84d5da222e9fbaa069b426e818438ec9f6`
- before heap: `de42e7286fb306e2cccec106e72168444ea8b1df2f5c4abb4a820b7cd6673864`
- after CPU: `f34b426ab1828e819ba58d64f551b068e08aef9d6ab46772a859ef1f69a1afd2`
- after heap: `7c731aca7d6b0e023edc045e2f7caf3fce95e4d4fc594379229133e91e30ad2b`

The only collector behavior change removes the incorrect nonnegative CPU delta condition; exact integer typing remains mandatory. Controls compare against the existing qualified signed-delta parser, preserve -1 unchanged, reject bool/float/string values, and exercise -1 through the actual collector with full 5,077,477-byte output validation. The old blocked source/tests/index/plans remain preserved unadmitted-v1.

Independently verified all four complete plan digests, 72 current pins each, resource bytes/memberships and fresh directories containing only plan.json. Prior review of exact artifacts, whole oracle, interpreter-before-helpers/captured-source bootstrap, one internal lock, progressive guards, completed-result ledger, partial profile capture and unconditional receipts remains applicable; those collector bodies are unchanged. Same Node24.20/CPU5/cap5, CPU100µs and heap8192B settings, no emission.

This admits serial once-only diagnostic capture subject to coordinator routing. Whole-process CPU snapshots, sampled retained heap at exit and Linux reaped subprocess-subtree ru_maxrss (including runner+Node) retain their original limits. No timing speedup, allocation-traffic, stock compiler or public adoption claim is established. Reviewer ran no profile child.
