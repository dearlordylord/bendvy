# R-A: Safe capability provider experiment

**Status:** published, `ready-for-agent`. [GitHub #14](https://github.com/dearlordylord/bendvy/issues/14). The user approved publication and execution.

## Parent and evidence

- [Full specification](../SPEC.md), [parent #1](https://github.com/dearlordylord/bendvy/issues/1).
- [T03 negative report](../../experiments/t03/README.md): exported constructors allow fabrication of a write grant.
- [T12 redesign checkpoint](../t12-redesign-decision.md): R-A precedes the conditional R-B alternative.

## What to build

Investigate a minimal Bend-native provider that supplies a system with declared read/write capabilities without exposing a way for application code to fabricate additional authority. Preserve affine ownership and repeated callback execution on the current compiler. A successful probe does not select the production query/storage API.

## Acceptance criteria

- [ ] Record the Bend version, guide, pinned references and trusted-provisioning/application-system boundary. Identify declarations and constructors accessible to application systems and the mechanism preventing fabrication. An instruction not to import a symbol is not a type boundary.
- [ ] Orchestration owns Motion storage; the callback receives only declared capabilities. Execute three successive steps reading Velocity=2 and writing Position, starting at Position=0. Observe Positions 2, 4, 6. Native and JavaScript outputs match a Node-only reference adapter at the same checkpoints.
- [ ] Direct write-through-read, undeclared access, cross-schema token misuse and reconstruction of a write grant from a read input are rejected for the intended type/authority reason. Each negative fixture has a minimal positive control. The cross-schema fixture uses a distinct second schema/token; a second complete world is outside this probe.
- [ ] Fabrication controls cover publicly accessible grant-creation paths rather than only the old constructor name. Demonstrate that the trusted provider can safely provision a legitimate grant. Rejecting all operations or retaining an unfilled declaration is insufficient.
- [ ] Return storage ownership correctly. Do not bypass the gate using whole-world access, unsafe/foreign authority constructors, backend-only stubs or unfilled laws. Captured state, affine-payload rollback and full R2 remain explicitly open.
- [ ] Record specific candidate statements and falsification results before proof work. Write no ECS proofs without separate approval of the laws. Finite probes do not establish universal refinement.
- [ ] Provide one reproducible runner checking controls, intended diagnostics and runtime outputs. Limit checker/build invocations to five seconds; timeout, unrelated error or skip is not an intended rejection. New dependencies require concrete approval.
- [ ] Distinguish a safe result, a counterexample and an inconclusive result. Record commands and limits of the conclusion. A negative result is not a language-wide impossibility claim.

## Outcome gates

A safe result allows preparation of the next integration experiment with two compositionally distinct schemas and full R2. One Motion probe does not close the original T03 capability gate. A negative or inconclusive result returns to human review and opens discussion of R-B. This ticket does not approve checked actions, compiler changes or a reduction of callback/core scope. Proof, simulation and performance gates remain in force.

## Delivery

The user reviewed and approved this experiment. The coordinator creates a separate issue and runs it through Dalph in the exact task worktree. Proposed artifacts belong in `experiments/ra-provider/`; no implementation exists there yet. The executor commits a candidate; the coordinator/integrator owns delivery and records Dalph feedback in `DALPH.md`.
