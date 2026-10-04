# Delegated decision: owned binder and arithmetic proof subjects

**Date:** 2026-10-04. **Decision maker:** Astra, acting under the user's explicit delegation:

> с астрой проверь - она тебе апрувнет

This delegates these two pending approval decisions, not general project approval. I reviewed the exact source blocks, their runtime/specification callers, installed Bend 2.0.34 Base/quantity rules, construction diagnostics and recorded falsification evidence. Decisions below authorize proof development; they do not certify an unproved statement or complete #18.

| Proposal | Decision | Exact approved subject |
| --- | --- | --- |
| Owned theorem binder revision | **APPROVE** | `owned_runtime_schedule_correspondence` in [PROPOSED.bend](../../experiments/p-owned-route/PROPOSED.bend), SHA256 `8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b` |
| Supporting arithmetic selection | **APPROVE** | `u32_increment_no_wrap` and `u32_comparison_agrees_nat` in [ARITHMETIC-PROPOSED.bend](../../experiments/p-observe/ARITHMETIC-PROPOSED.bend), SHA256 `7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937` |

## Owned theorem: reason and boundary

Mechanical block comparison confirms the sole statement change from the original catalogue is `for -world: R.World` becoming `for world: R.World`. The entire `S.run_safe` predicate and both observation endpoints are identical. Original catalogue SHA256 remains `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.

The revision preserves quantification over every `R.World` and the same independent admissible/prefix-safe domain. It changes permission to use the proof input: the world is live affine, not reusable. Repeated occurrences inside the proposition do not authorize runtime cloning. A proof may consume that input once or thread its owner through lawful proof-local construction; this does not change a production runtime API or promise that proving an equation returns a usable runtime world. The two function types are not claimed equivalent in Bend's quantity-sensitive theory.

This is an appropriate repair for the demonstrated construction problem. Installed rules prohibit the tested uses of an erased world as a live conditional discriminant or evidence source. The actual-world live constructor legally introduces the conditional when supplied the equation, and the nonliteral empty-row family constructs a narrower complete inhabitant. These establish relevant feasibility, not the general revised theorem. Failed erased/dead/template/closure/witness routes do not establish impossibility of the original theorem, and approval does not depend on such an impossibility claim.

The contract remains meaningful: actual `R.tick`/projection observation must agree with independent schedule semantics over every safe prefix. It observes element zero of each payload and public metadata/ordered rows/pending commands. It does not establish physical owner identity, other array elements, general Type payload preservation, unforgeable roots, reader transactions or a production scheduler. Full correspondence still needs actual ownership/projection, primitive-step, prefix and arithmetic derivations. Further signature or premise changes require another explicit decision; none is licensed implicitly by this approval.

## Arithmetic: reason and boundary

Both selected blocks exactly match their original catalogue statements. `B.increment` is actual `U32.add(value,1)`; `B.less` is actual `U32.is_lt`. These are useful supporting contracts for transferring runtime decisions and updates to Nat observations, not stand-alone ECS user guarantees. The installed structural Word definitions make their intended unsigned semantics clear. The existing checked add-one/inc linkage does not already prove conversion without wrap.

The increment subject excludes MAX through its explicit guard and demands Nat successor below it; it makes no claim about wrapped MAX. The comparison subject covers every U32 pair. Neither freezes allocator reuse/exhaustion behavior. Their role is justified by actual Reserve comparison/addition and Bump addition; connecting them to Reserve bounds, prefix-safe Bump premises and Publish/key equality remains required. They are not asserted to be the only possible mathematical decomposition or sufficient alone for owned correspondence.

Recorded falsification contains four increment and sixteen comparison equations over 0/1/2/255, with compiling +2 and reversed-comparison mutants rejected at true-domain own-statement witnesses. Those finite checks support the intended meaning, not universal truth. Compiled MAX−1/MAX boundary observations do not verify the high-bound Nat equations. General structural proofs, checker/kernel acceptance within five seconds and appropriate unchanged-proof mutation gates remain outstanding. No unary MAX expansion, new dependency or timeout increase is approved.

## Effective authorization and retained gates

Proof work may now target the exact revised owned statement and these two exact arithmetic statements, with ordinary contextual mathematical dependencies. This approves neither an alias of any remaining unapproved catalogue law nor an additional public contract. The six previously approved pure endpoints retain their existing scope; **22 other catalogue candidates remain unapproved**. Historical original/proposal files were not edited. Their historical “UNAPPROVED” comments describe the pre-decision state; this dated exact-hash record supplies the new authorization.

No other law, foreign-command or allocator policy, payload restriction, numerical performance threshold, production layout, dependency, integration capability or completion claim is approved here. The delegated approval is complete for these exact subjects; no further approval question is needed merely to start their proofs. Acceptance still requires the proofs and their actual endpoint/caller evidence, followed by review.
