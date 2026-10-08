# Ordinary query constructor candidate (#56)

Experimental source-only implementation against root `17ab9819`; this does not
complete #56. No backend has been run and no new contract or law is adopted.

`declaration.bend` constructs read/write/optional and with/without/added/changed
clauses together with actual Compose grants and matchers. Inputs are the ordinary
canonical declaration and closed storage/view recipes. Family is constructed
internally through the existing declared-family bridge; there is no user metadata
argument, separate descriptor inventory or manual debug adapter. Arbitrary Type
payloads remain affine. `pair` combines typed grants, ordered clauses and
short-circuit matching. Filter-only constructors give Unit, never body writes.

`application.bend` specializes every constructor to the existing canonical
snapshot fixture's arbitrary Array payload and real storage lenses. It consumes
read, replacement, optional read and lifecycle matcher operations on actual
Compose Frames, and specializes the read/write/optional product. This is a
consuming source witness, not a complete multi-entity application execution.

Integration interface: root's ordinary system facade receives the declaration,
uses its grant/selector for the executable query, and derives access/debug fields
from its clauses. `observe` returns the declaration owner plus detached clauses;
`grant`/`selector` are closed-template projections as in existing Compose Plan.
No independently supplied access list is needed. Root alone changes production
Compose/System/App and bindings to actual registered IDs/schedule steps.
Existing canonical declaration/Family ownership remains with its assigned owner.

Development checks use `scripts/bend-check` at the existing five-second limit,
`BEND_NO_TELEMETRY=1`. Raw stdout and compressed unmodified stderr are retained.
Final application source check passes; three source negatives terminate at the
intended boundaries: wrong schema, write grant from read declaration, duplicated
affine declaration. JSON records bind candidate bytes, not a full installed-tool
or dependency-closure delivery qualification. The first invalid Absent spelling
attempt and earlier positive diagnostics remain historical development records;
their old raw outputs are not rebound to the final candidate.

Remaining work, not narrowed away:

- Execute composed multi-family required read/write/optional and all filter
  variants on nonempty worlds; this fixture currently specializes the same
  component declaration. Optional absence and lifecycle cursor behavior require
  independently authored full semantic oracle before backends.
- Retain query slot and canonical identity at ordinary system parameter grouping;
  constructor clauses alone are not the full published debug description format.
- Consume this declaration in ordinary registered System/App with Enabled versus
  Disabled behavior and actual schedule identity/placements. No App debug switch
  is implemented by these files.
- Validate source-current semantic/error controls, independent mode/filter
  projection and executable-matcher mutants, full owner/noninterference results,
  JS/Native delivery, and unchanged regression/equal-work performance gates.
- Complete remaining relation/machine and public debug surface obligations under
  existing tickets; do not resolve #50/#53 policy through this experiment.
