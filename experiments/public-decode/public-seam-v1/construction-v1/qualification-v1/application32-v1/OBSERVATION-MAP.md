# Application32 whole observation contract

This is an oracle-authoring map, not an expected-output file. Derive values from
source and retained canonical semantics; do not consult interpreted/generated
stdout. Preserve all 32 original cases in case-inventory.json.

| TS public observation | Bend whole observation | Interpretation |
| --- | --- | --- |
| root / operation / name | Item schema / operation / name | Exact case order; Workshop and Garden are distinct type indexes. |
| original owned input | Report.original | raw, both words, both flags retained. |
| checked raw result | Report.result | Constructor validation then immediate write/deferred request/resource admission; exact canonical Raw or error path and rejected Input. |
| incomingAfter | original plus returned Input or installed Owner view | TS mutable reference and Bend affine move differ; compare semantic input/sentinels, not alias identity. Owner.original retains original Raw while Owner.raw is canonical. |
| before dump | Report.before | Actual initialized resource, entity Value and queued Marker, registration. |
| after dump | Report.committed | Immediate insert/resource already visible; spawn owner still prepared and its entity reserved, Marker still queued. |
| flushed dump | Report.barrier | Queued Marker and accepted spawn materialized at actual delivery. |

Every Snapshot also retains Meta(namespace,nextId,highWater,capacity,depth,events,
registrations,nextSystemId,clock), complete physical liveness, Value column
supported flag/slots/lifecycle entries, Marker slots/lifecycle entries, all returned
packets/errors, complete resource View, pending command count. These internal
observations are checked against a whole Bend model, not compared numerically to
TS storage internals. Lifecycle and consumed IDs follow established Bend source.

InstanceView retains namespace/id/name/access, complete Local recoveries and
Pending owner/error views. Result includes success/output, failure/error, or
invocation refusal/input/operation/target. Operation success retains entity handle,
spawn flag, canonical Raw and undo availability; resource success retains canonical
Raw and undo availability. Refusals retain complete original Input and canonical
error algebra. SetupRefused is observable and must never replace a successful
reference trace without a model mismatch.

## Work and representation domain

Both execute eight identical Raw/codec cases, two native schema indexes, real
world/resource initialization, trusted typed component seed, queued transient
Marker and one registered system invocation. Insert enumerates declared Value
membership twice and writes the selected entity immediately; Spawn constructs and
enqueues, then delivers; resource constructs and writes immediately. Both validate
the resource seed during application setup. The Bend constructor is an explicit
reversible affine owner builder; no dummy raw projection or host callback is used.

TS callbacks/schema wrappers versus Bend retained typed declarations are language
mechanisms. Any timing must state whether input DTO creation, setup, complete dump
observation and delivery are inside its interval; current reference includes them.
No timing criterion or conversion-cost waiver is established by these files.

Selector helper algebra and Standard Schema host integration are outside these
32 traces and pending approved scope. Foreign-world numeric coincidence is governed
by approved world-qualified Bend handles; no foreign-world scenario is invented
in this equivalent workload. Full typed errors and rollback are already qualified
in immutable canonical92+native22; this workload adds no ownership policy.
