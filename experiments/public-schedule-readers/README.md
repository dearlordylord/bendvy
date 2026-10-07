# Public schedule reader integration (#35)

This harness executes the public Schedule runner with actual Event.Runtime,
Removals.Reader and tracked System.Registry owners. The independently observed
TypeScript oracle imports the pinned upstream core directly with Node; it is not
an alternative reader state machine. `node reference.mjs --verify` checks the
frozen 25 checkpoints, including complete owned array payloads and the 65,535
publication retention boundary.

`python3 run.py` runs bounded checker, JS and Native semantics, intended access
and ownership rejection controls, and compiling mutation controls. Native uses
the existing private Clang19 installation. Limits remain checker5 / emit30 /
Clang120 / runtime5 seconds. No performance cohorts or profiling are part of
this run; elapsed infrastructure work does not qualify performance.

The schema's Stock and Aux payloads contain affine Arrays. Aux uses the ordinary
Queue family implementation from the independently authored Workshop schema.
Gameplay changed-reader callbacks receive only the abstract shared owner and
closed component capabilities. Full payload projections retain arbitrary
logical lengths; the observation does not compare only leading words.

The domain adapter moves the affine World into the actual Event runtime while
keeping the removal log outside its event retention policy. After transport it
returns the complete World owners and ordinary event metadata. The application
classifies its closed Notice sum into Ping versus removal/despawn notices;
component owners are never put into a Data log. Schedule's additive skip hook
invokes the actual event skip policy, while changed/removal skips leave their
actual cursors intact. Empty affine slots represent owners currently moved into
a call; there are no fabricated zero registrations.

The main trace covers independent fast/slow readers, conditions, deferred
visibility, earlier successful commits before later failure, failed publication,
failed reader retry, changed-reader own-write rollback and post-write consumption,
removal/despawn backlog, and lag/retention. The changed-reader failure fixture
selects one row: its failed observation comes from the actual row transaction
error. It does not claim aggregate failed observations for an arbitrary number
of prior successful rows.

`lifecycle-controls.bend` adds scheduled disposal and late re-registration for
all three kinds after actual publication, changed payloads and removal. Its
expected observation is a Bend-only scoped control, not a paired upstream
TypeScript disposal result. `domain-controls.bend` checks stable partitioning
with an affine Array resource, including actual Event.run and recovery. The retained `evidence/intermediate25` oracle is
the earlier trace before adding unread publication at a skipped event reader;
that earlier skip mutant survived and is not acceptance evidence.

Source-current semantics pass: see [REPORT.md](REPORT.md) and the retained
[evidence receipt](evidence/source-current/receipt.json). Both backends match
25 composed and four Added+Changed TS checkpoints, pass five scoped controls,
and detect seven compiling mutations. Mixed event-reader recovery also checks
peer retention/lag, skip, removal visibility and consumed own publication.

Independent reviews, unchanged paired regression, feature-specific performance
and coordinated delivery remain open. This is finite trace evidence, not a
proof, universal runtime refinement, a production registration-authority API,
full public-core parity, or performance qualification.
