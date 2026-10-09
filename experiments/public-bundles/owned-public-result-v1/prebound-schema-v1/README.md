# Registration-time immutable declaration binding — isolated candidate

Repeated source path: `bundle-provider.provision_declared` calls
`schema-fragments.bind_declared`, which traverses kind-local entries and required
keys/names every time. Bundle schema-a/schema-b call this from `invoke`; their
`Args.declared` is dynamic. The profile's six String.cmp samples / 2.542 ms do
not establish causal dominance or a speedup opportunity by themselves.

The candidate binds immutable entries/requirements once while constructing the
**actual existing System registration**, then repeats ordinary `Sy.run`. It adds
no Ready/Bool permit, new registry, cached validation constructor or captured
owner-sharing policy. The generic bind returns existing SF.Bound: declaration
refusal returns the exact complete World owner before the initializer is called;
registration failure remains a separate existing System result.

Threat model is the existing trusted closed schema initializer, not arbitrary
hostile source. SF.Entry/Fragment and System.Registry constructors are public;
the candidate does not make them cryptographically or type-theoretically sealed.
Calling an unrelated initializer directly can bypass its schema declaration, as
in current provisioning. The admitted candidate path always calls the real
validate → requirements → initializer pipeline, preserving duplicate-before-
requirement error ordering. No fabricated proof or constructor is used as a new
permission to execute a body.

`main.bend` consumes arbitrary affine Array resource owners in two schema types,
registers once and performs two actual registered reads per accepted schema.
The same consuming source preserves missing-requirement and duplicate-key
rejection World owners. Every body still reaches unchanged System namespace and
registration checks; actual requests retain their existing foreign/liveness/
read/write/transaction validation. Dynamic providers must retain the existing
per-invocation bind route. In particular, current Args.declared=False refusals
cannot be moved to registration or silently skipped.

Source5 checks: full consumer passes; cross-schema System registry, duplicate
World owner, read-only write and undeclared owned-request grant controls fail at
the intended operation/type boundary. Raw results and earlier constructor-name
failure are retained. These are source controls, not runtime semantic evidence
or universal proofs. No law or new ownership/finalizer contract is introduced.

Remaining before adoption: integrate immutable registration binding into an
isolated copy of the complete matched ten-world/40-invocation consumer, keeping
dynamic provider/error paths and full observations unchanged; independent whole
oracle and reached wrong-binding controls; source-bound JS/Native qualification;
then matched before/after timing and allocation if semantic qualification passes.
No backend plan, execution, performance result or shared-core promotion is claimed.
