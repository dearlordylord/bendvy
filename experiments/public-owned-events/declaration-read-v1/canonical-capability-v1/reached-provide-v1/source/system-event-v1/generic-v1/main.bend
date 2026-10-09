import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/system-event-v1/generic-v1/controls.bend as C
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/registered-v1/observation.bend as O
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/registered-v1/direct-controls.bend as Direct

type OwnerMeta is Data: OwnerMeta{slot:String,clauses:List<&2,Query.Clause<F.Schema>>}
type Snapshot is Data: Snapshot{fastOwner:OwnerMeta,slowOwner:OwnerMeta,state:O.Snapshot}
def observed(+fastSlot:String,+fastClauses:List<&2,Query.Clause<F.Schema>>,+slowSlot:String,+slowClauses:List<&2,Query.Clause<F.Schema>>,result:F.Host & O.Snapshot) -> C.Host & Snapshot:
  match result:
    case (host,state): (C.Host{host,fastSlot,fastClauses,slowSlot,slowClauses},Snapshot{OwnerMeta{fastSlot,fastClauses},OwnerMeta{slowSlot,slowClauses},state})
def snapshot(label:String,owner:C.Host) -> C.Host & Snapshot:
  match owner:
    case C.Host{host,fastSlot,fastClauses,slowSlot,slowClauses}: observed(fastSlot,fastClauses,slowSlot,slowClauses,O.snapshot(label,host))
type Action is Data:
  Activate{}
  PublishFirst{}
  PublishNext{}
  Fast{}
  SlowFail{}
  Slow{}
  Skip{}
  DuplicatePublish{}
  Frame{}
  Foreign{}
type Step is Data: Step{label:String,action:Action}
type Trace is Data:
  Trace{snapshots:List<&2,Snapshot>}
  SetupRefused{}
def action(action:Action,host:C.Host) -> C.Host:
  match action:
    case Activate{}: C.read(C.read(host,True{},False{}),False{},False{})
    case PublishFirst{}: C.publish(host,[F.packet(1,11),F.packet(2,21)])
    case PublishNext{}: C.publish(host,[F.packet(3,31)])
    case Fast{}: C.read(host,True{},False{})
    case SlowFail{}: C.read(host,False{},True{})
    case Slow{}: C.read(host,False{},False{})
    case Skip{}: C.skip(host)
    case DuplicatePublish{}: C.publish(host,[F.packet(1,91)])
    case Frame{}: C.frame(host)
    case Foreign{}: C.foreign(host)
def checkpoint(next:C.Host -> List<&2,Snapshot> -> Trace,+previous:List<&2,Snapshot>,observed:C.Host & Snapshot) -> Trace:
  match observed:
    case (host,view): next(host,List.append(&2,Snapshot,previous,[view]))
def steps(items:List<&2,Step>,host:C.Host,previous:List<&2,Snapshot>) -> Trace:
  match items:
    case []: Trace{previous}
    case Step{label,op} <> rest: checkpoint(host => views => steps(rest,host,views),previous,snapshot(label,action(op,host)))
def initial(items:List<&2,Step>,first:C.Host & Snapshot) -> Trace:
  match first:
    case (host,view): steps(items,host,[view])
def started(items:List<&2,Step>,start:C.Started) -> Trace:
  match start:
    case C.Started{host}: initial(items,snapshot("registered",host))
    case _: SetupRefused{}
def standard() -> Trace:
  started([Step{"skip-inactive",Skip{}},Step{"activate",Activate{}},Step{"publish-first",PublishFirst{}},Step{"fast",Fast{}},Step{"slow-failed",SlowFail{}},Step{"slow-retry",Slow{}},Step{"fast-repeat",Fast{}},Step{"publish-next",PublishNext{}},Step{"skip-fast",Skip{}},Step{"fast-after-skip",Fast{}},Step{"slow-next",Slow{}},Step{"duplicate-publication",DuplicatePublish{}},Step{"window-first",Frame{}},Step{"window-second",Frame{}},Step{"foreign-reader",Foreign{}}],C.start(8n))
def capacity() -> Trace:
  started([Step{"activate",Activate{}},Step{"publish-first",PublishFirst{}},Step{"publish-next",PublishNext{}},Step{"whole-batch-capacity",Frame{}},Step{"fast-lagged",Fast{}},Step{"slow-lagged-failure",SlowFail{}},Step{"slow-lagged-retry",Slow{}}],C.start(2n))
type Batch is Data: Batch{standard:Trace,capacity:Trace,missing:Direct.DirectView,duplicateRows:Direct.DirectView,duplicatePublication:Direct.DirectView,ownedOutput:Direct.DirectView}
def main() -> Batch:
  Batch{standard(),capacity(),Direct.missing(),Direct.duplicate_rows(),Direct.duplicate_publication(),Direct.owned_output()}
