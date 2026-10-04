# Contextual owned-runtime arithmetic inventory

Persisted before proof/check development. Governing task: approved owned schedule endpoint, original catalogue SHA256 e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc. Full runtime theorem and binder revision wait for approval. No standalone arithmetic contract is promoted.

Installed Bend 2.0.34; `bend version` and `bend guide` read. Installed `/home/node/.bend/bend2/base.bend` supplies Word.zero/inc/adc/add/cmp/to_nat and U32 wrappers; proved arithmetic availability is Word.add_comm and U32.add_comm. No Word conversion/order/carry proofs exist there. No vendor directory or PUBLIC_API.lock found under installed Bend or /workspace/formal-proofs; no library installed. Installed source, not newer pinned source, governs this experiment.

Actual callers: Reserve branches on U32.is_lt(next,limit), then U32.add(next,1); Publish/modify/Bump compare U32 keys for equality; Bump reads array element zero then U32.add(value,1). Necessary future links: comparison of projected keys; bounded reserve increment; prefix-safe bump increment; array read/write observation (not arithmetic scope).

Approval boundary: proving general U32 less-than/Nat agreement would reproduce unapproved u32_comparison_agrees_nat. Proving global below-MAX successor conversion would reproduce unapproved u32_increment_no_wrap. Reported to coordinator before proofs; neither is a target here. Also do not fill conditional_type_true/false.

Bounded target inventory:
1. Structural ADC with all-zero second word and False carry preserves the first word; True carry implements Word.inc. This links actual add machinery to carry propagation without any Nat conversion/no-wrap claim.
2. Structural all-zero conversion and a clear-low-bit increment conversion; carry-step conversion under an explicit tail successor equation. These are local constructor cases, not the global conditional no-wrap bridge.
3. Equality/comparison reflexivity on structural words for key-equality proof preparation; do not prove general comparison conversion.
4. Five-second checker and kernel checks, small literal carry controls and deliberately false mutation of a dependency to demonstrate sensitivity. Record exact open links.

No MAX unary expansion, new dependency, runtime/core edit, or unapproved ECS proof. Files owned only in experiments/p-owned-arithmetic, isolated proof-owned-arithmetic worktree.
