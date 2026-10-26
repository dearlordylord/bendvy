# Replacement execution consumer

This application exercises the new ordinary `execution-app` declaration,
registration and repeated-run entry. It currently runs one system sequentially.
It supplies no handwritten World execution adapter.

`declarations.bend` declares a position component and counter resource through
library product paths. Position and label columns own separate chunk trees.
The resource product owns a counter and secret separately. Every payload and
system Local contains an affine Array token. `body.bend` receives an abstract
scope and the declared component/resource capabilities, never World storage.

The application runs the same scenario in two nominal schemas. Sixteen actual
reserved handles become live. Position membership is sparse at indices 1 and
16, and label membership is at index 2. Both columns grow beyond their initial
leaf. The system increments position 1 by one and the counter by ten per run.
Run two returns a body error after both writes. Runs one and three succeed.
The actual retained system is then submitted to another World created from the
advanced factory; admission refuses before invoking its body.

The complete output includes both position tokens/values, an absent position,
the untouched label, counter and secret tokens, live and registration counts,
retained Local token/run count, and the returned foreign World's observations.
This distinguishes retained partial mutation from rollback and distinguishes
refusal from another body invocation.

`controls/positive.bend` checks a normal abstract getter. The other controls must
fail for their named authority boundaries. They use the same affine payloads
and getter/mutation operations as the consumer. Raw schema provisioning is a
trusted boundary, as with the existing component family bindings. The explicit
`execution-projection.trusted_affine` token does not prove that an owner-returning
projector is pure. Every current affine projector requests exclusive access;
read-only describes the gameplay grant and does not authorize a shared runtime
alias. Component projections conservatively stamp the selected row because an
affine projector can replace its owner. A genuine shared detached Data view and
final lifecycle semantics remain separate replacement-executor work.

The new modules are provisional until the integrated Spec and Standards review,
source-bound backend evidence, affected normal checks and applicable law process
complete. This fixture does not establish native concurrency, universal owner
preservation, shared-read purity or completed issue #78 acceptance. The remaining
ordinary consumers still require migration through the later #77 slices.

Ordinary registration now accepts `execution-builder.Program` instead of a raw
capability/catalog pair. The declaration is polymorphic over both its hidden
scope and affine metadata accumulator. Builder grant primitives return the
updated accumulator together with their capability, so retaining a generated
grant while discarding its recorded access requires reusing the consumed old
accumulator. Controls reject that reuse, fabricating an empty accumulator and
injecting a getter for the concrete scope. The raw declaration constructor is
an internal lowering shape and is rejected at the ordinary App entry.

Physical schema adapters remain a separate trusted boundary. The builder
currently accepts typed product lenses and nominal identities from provisioning;
it does not prove that an arbitrary user-authored lens corresponds to its key.
Schema-derived identity/path coupling remains required follow-up work. Structural
owner partitioning must remain the parallel executor's safety invariant regardless
of metadata names.

`check.sh` uses the shared example runner, checks the positive and negative
controls, and compares the complete finite output with `expected.stdout`. Set
`BENDVY_EXAMPLE_NATIVE=1` to include native runs with one and four workers. The
observation enumerates every physical slot and lifecycle stamp in both columns,
allocator slots/free/order/progress, registrations, clock/scopes, queue and event
counts, resource owners, system metadata/cursor, Local and the refused foreign
World. Empty queues and Unit events have no omitted payload observations.
The expected output derives from three one-step movements and three ten-step
counter increments, including the second run's error, plus unchanged sparse
membership and the foreign World's refused invocation. Its independent review
is part of the final verification gate.
