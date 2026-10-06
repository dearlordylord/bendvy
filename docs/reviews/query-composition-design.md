# General query composition design — implementation checkpoint

Issue [#27](https://github.com/dearlordylord/bendvy/issues/27). This records the
reviewed language mechanism before integration; it is not a completion report.

The caller defines an ordinary `Ops(H)` record containing independently typed
read, write and optional capabilities. The callback is checked for arbitrary
affine `H` and returns that same owner. The executor specializes a **closed**
capability record; getter/setter projections become closed template arguments.
The library entry point has no component-count-specific binders. All capability
aliases thread one context, so repeated declarations see current shared storage.
Independent presence/absence predicates compose conjunctively with selection.
Caller-defined type constructors and closed adapters are trusted provisioning;
the executor does not certify arbitrary `Ops(H)` as an operation-only record.
Confinement acceptance therefore tests concrete public declarations rather than
claiming universal authority for malicious factories.

Independent language investigation exercised three heterogeneous capabilities,
an actual affine Array, repeated reads and two setters on compiled JS and Native.
Write through read, context duplication, concrete reconstruction and passing an
open runtime capability as a closed template reject at their intended seams.
These are mechanism controls; integration must repeat them against public ECS
operations and the frozen [Workshop oracle](../../examples/query-composition/scenario.md).

The unchanged kernel cannot model the generic higherkind callback: `--verdict`
reports a missing model, also reproduced on the existing provider. Ordinary
checking and compiled observations do not establish a universal proof. No
compiler/kernel repair, new law, dependency or proof approval follows. Recursive
composition remains subject to the compiler's existing template-depth limit.

Integration requirements: typed schema provisioning, no ambient grants, exact
membership and ascending iteration, one transaction across all selected rows,
complete owned replacement rollback, repeatable registered systems, empty
selection and shared aliases. Preserve existing consumers and check fresh
JS/Native observations and negative controls. The reference contract separately
identifies lifecycle/relation combinations; structural composition alone cannot
be reported as complete bevy-ts parity.
