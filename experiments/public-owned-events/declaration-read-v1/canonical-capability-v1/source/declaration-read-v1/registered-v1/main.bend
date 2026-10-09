import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/observation.bend as O
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/direct-controls.bend as Direct

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
  Trace{snapshots:List<&2,O.Snapshot>}
  SetupRefused{}
def action(action:Action,host:F.Host) -> F.Host:
  match action:
    case Activate{}: F.read(F.read(host,True{},False{}),False{},False{})
    case PublishFirst{}: F.publish(host,[F.packet(1,11),F.packet(2,21)])
    case PublishNext{}: F.publish(host,[F.packet(3,31)])
    case Fast{}: F.read(host,True{},False{})
    case SlowFail{}: F.read(host,False{},True{})
    case Slow{}: F.read(host,False{},False{})
    case Skip{}: F.skip(host)
    case DuplicatePublish{}: F.publish(host,[F.packet(1,91)])
    case Frame{}: F.frame(host)
    case Foreign{}: F.refuse_reader(host)
def checkpoint(next:F.Host -> List<&2,O.Snapshot> -> Trace,+previous:List<&2,O.Snapshot>,observed:F.Host & O.Snapshot) -> Trace:
  match observed:
    case (host,view): next(host,List.append(&2,O.Snapshot,previous,[view]))
def steps(items:List<&2,Step>,host:F.Host,previous:List<&2,O.Snapshot>) -> Trace:
  match items:
    case []: Trace{previous}
    case Step{label,op} <> rest: checkpoint(host => views => steps(rest,host,views),previous,O.snapshot(label,action(op,host)))
def initial(items:List<&2,Step>,first:F.Host & O.Snapshot) -> Trace:
  match first:
    case (host,view): steps(items,host,[view])
def started(items:List<&2,Step>,start:F.Started) -> Trace:
  match start:
    case F.Started{host}: initial(items,O.snapshot("registered",host))
    case _: SetupRefused{}
def standard() -> Trace:
  started([Step{"skip-inactive",Skip{}},Step{"activate",Activate{}},Step{"publish-first",PublishFirst{}},Step{"fast",Fast{}},Step{"slow-failed",SlowFail{}},Step{"slow-retry",Slow{}},Step{"fast-repeat",Fast{}},Step{"publish-next",PublishNext{}},Step{"skip-fast",Skip{}},Step{"fast-after-skip",Fast{}},Step{"slow-next",Slow{}},Step{"duplicate-publication",DuplicatePublish{}},Step{"window-first",Frame{}},Step{"window-second",Frame{}},Step{"foreign-reader",Foreign{}}],F.start(8n))
def capacity() -> Trace:
  started([Step{"activate",Activate{}},Step{"publish-first",PublishFirst{}},Step{"publish-next",PublishNext{}},Step{"whole-batch-capacity",Frame{}},Step{"fast-lagged",Fast{}},Step{"slow-lagged-failure",SlowFail{}},Step{"slow-lagged-retry",Slow{}}],F.start(2n))
type Batch is Data: Batch{standard:Trace,capacity:Trace,missing:Direct.DirectView,duplicateRows:Direct.DirectView,duplicatePublication:Direct.DirectView,ownedOutput:Direct.DirectView}
def main() -> Batch:
  Batch{standard(),capacity(),Direct.missing(),Direct.duplicate_rows(),Direct.duplicate_publication(),Direct.owned_output()}
