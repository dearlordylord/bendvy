import Base
import ../../../../src/ecs/local.bend as LocalCore
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/system-instance.bend as SI
import ./fixture.bend as F
import ./setup.bend as Setup
import ./events.bend as Events
import ./readers.bend as Readers
import ./machine-reader.bend as Machine
import ./locals.bend as Local
import ./held.bend as Held
import ./input.bend as Input
import ./observe.bend as Observe
import ../../basic-world-statefree-v1/observe.bend as O
import ../../basic-world-statefree-v1/model.bend as Model
import ../../basic-world-statefree-v1/events.bend as OldEvents
import ../../../../src/ecs/restore-graph-data.bend as Graph
import ./core/restore-graph-runtime.bend as Restore
import ../../../../src/ecs/restore-graph-raw-owner.bend as RawOwner
import ../../../../src/ecs/restore-graph-raw.bend as Raw
import ../../../../src/ecs/restore-public.bend as Basic
import ../../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../../src/ecs/restore-data.bend as Change
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/relation-failure-runtime.bend as Failure
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ordinary
import ../../../../src/ecs/ordinary-machine-transition-reader.bend as MachineRead
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/decode-data.bend as D

type Session<S:Data> is Type:
  Session{runtime:F.RuntimeType(~S),owner:F.Owned(~S),held:Held.Owners<S>,saved:Graph.Snapshot,input:D.Raw,report:String}
type Step<S:Data> is Type:Continue{session:Session<S>} Stopped{report:String}
type Operation is Data:
  Checkpoint{label:String}
  Read{}
  LocalRun{}
  Initialize{}
  Spawn{value:U32,barrier:Bool}
  Seed{}
  Pending{}
  Publish{value:U32}
  Save{}
  Restore{kind:U32}
  InsertMode{}
def checkpoint_joined(~S:Data,label:String,+saved:Graph.Snapshot,+input:D.Raw,report:String,r:F.RuntimeType(~S) & String,o:F.Owned(~S) & String,h:Held.Owners<S> & String) -> Step<S>:
  match r o h:
    case (runtime,rt),(owner,ot),(held,ht):Continue{Session{runtime,owner,held,saved,input,report ++ label ++ "|runtime=" ++ rt ++ "|owner=" ++ ot ++ "|held=" ++ ht ++ "|saved=" ++ Observe.snapshot(saved) ++ "|input=" ++ O.raw(input) ++ "\n"}}
def checkpoint(~S:Data,label:String,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,saved,input,report}:checkpoint_joined(~S,label,saved,input,report,Observe.runtime(~S,runtime),Observe.owner(~S,owner),Observe.held(~S,held))
def changed(~S:Data,owner:F.Owned(~S),held:Held.Owners<S>,saved:Graph.Snapshot,input:D.Raw,report:String,change:F.World(~S) -> F.World(~S),result:F.World(~S) & (Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat)) -> Step<S>:
  match result:
    case (world,metadata):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,change(world),metadata),owner,held,saved,input,report}}
def transform(~S:Data,change:F.World(~S) -> F.World(~S),session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,saved,input,report}:changed(~S,owner,held,saved,input,report,change,Mixed.split(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,runtime))
def seed(~S:Data,world:F.World(~S),handles:List<&2,W.Handle<S>>) -> F.World(~S):
  match handles:
    case +first <> +second <> +third <> _:Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,world,F.link(~S),third,second),F.link(~S),first,second),F.parent(~S),third,first),F.parent(~S),first,second),F.link(~S),first,first)
    case _:world
def seeded(~S:Data,owner:F.Owned(~S),held:Held.Owners<S>,saved:Graph.Snapshot,input:D.Raw,report:String,runtime:F.RuntimeType(~S),handles:List<&2,W.Handle<S>>) -> Step<S>:
  match runtime:
    case Route.Runtime{world,family,tick}:Continue{Session{Events.barrier(~S,Route.Runtime{seed(~S,world,handles),family,tick}),owner,held,saved,input,report}}
def seed_session(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,+handles},saved,input,report}:seeded(~S,owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report,runtime,handles)
def spawned(~S:Data,owner:F.Owned(~S),local:Local.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),failures:Readers.FailureReader(~S),machine:Machine.Owned(~S),args:Array<U32>,failureArgs:Array<U32>,machineArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:D.Raw,report:String,family:Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>>,tick:Nat,result:F.World(~S) & W.Reservation<S>) -> Step<S>:
  match result:
    case (world,W.Reserved{handle}):Continue{Session{Route.Runtime{world,family,tick},owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,List.append(&2,W.Handle<S>,handles,[handle])},saved,input,report}}
    case (_,_):Stopped{report ++ "spawn-refused\n"}
def spawn(~S:Data,value:U32,barrier:Bool,session:Session<S>) -> Step<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report}:spawned(~S,owner,local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles,saved,input,report,family,tick,Setup.spawn(~S,world,value,barrier))
def saved(~S:Data,owner:F.Owned(~S),held:Held.Owners<S>,input:D.Raw,report:String,metadata:Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat,result:F.World(~S) & Graph.Snapshot) -> Step<S>:
  match result:
    case (world,+snapshot):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,world,metadata),owner,held,snapshot,input,report ++ "save-returned|" ++ Observe.snapshot(snapshot) ++ "\n"}}
def saving(~S:Data,owner:F.Owned(~S),held:Held.Owners<S>,input:D.Raw,report:String,result:F.World(~S) & (Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat)) -> Step<S>:
  match result:
    case (world,metadata):saved(~S,owner,held,input,report,metadata,F.save(~S,world))
def save(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,_,input,report}:saving(~S,owner,held,input,report,Mixed.split(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,runtime))
def local_ran(~S:Data,owner:F.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),failures:Readers.FailureReader(~S),machine:Machine.Owned(~S),args:Array<U32>,failureArgs:Array<U32>,machineArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:D.Raw,report:String,metadata:Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat,result:Local.Returned(~S) & String) -> Step<S>:
  match result:
    case (LocalCore.Completed{world,instance,_},text):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,world,metadata),owner,Held.Owners{Ordinary.Owner{instance},reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "local-returned|" ++ text ++ "\n"}}
    case (LocalCore.Refused{world,instance,_},text):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,world,metadata),owner,Held.Owners{Ordinary.Owner{instance},reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "local-returned|" ++ text ++ "\n"}}
def run_local(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report}:local_ran(~S,owner,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles,saved,input,report,(family,tick),Observe.local_returned(~S,Local.run(~S,local,world)))
def chosen(kind:U32,saved:Graph.Snapshot) -> D.Raw:
  match kind:
    case 0:D.Object{[D.Field{"version",D.Number{1}},D.Field{"nextEntity",D.Number{5}},D.Field{"entities",D.Array{[]}},D.Field{"relations",D.Text{"not an object"}},D.Field{"resources",D.Object{[]}},D.Field{"machines",D.Object{[]}}]}
    case 1:Raw.encode(Input.bad_resource(Input.patched(saved,1)))
    case 2:Raw.encode(Input.cycle(Input.patched(saved,1)))
    case 3:Raw.encode(Input.patched(saved,9))
    case 4:Raw.encode(Input.floor(Input.patched(saved,1),131074))
    case 5:Raw.encode(Input.patched(saved,1))
    case 7:Raw.encode(Input.factory_refused(Input.patched(saved,1)))
    case 8:Raw.encode(Input.trial(8,Input.patched(saved,1)))
    case 9:Raw.encode(Input.trial(9,Input.patched(saved,1)))
    case 10:Raw.encode(Input.trial(10,Input.patched(saved,1)))
    case 11:Raw.encode(Input.trial(11,Input.patched(saved,1)))
    case 12:Raw.encode(Input.machine_trial(Input.patched(saved,1),True{}))
    case 13:Raw.encode(Input.machine_trial(Input.patched(saved,1),False{}))
    case _:Raw.encode(saved)
def restored(~S:Data,held:Held.Owners<S>,saved:Graph.Snapshot,input:D.Raw,report:String,result:F.RawReturned(~S) & String) -> Step<S>:
  match result:
    case (RawOwner.ParseRejected{owner,runtime,_,_},text):Continue{Session{runtime,owner,held,saved,input,report ++ "restore-returned|" ++ text ++ "\n"}}
    case (RawOwner.Delivered{_,Restore.Returned{runtime,owner,recovery,receipt,_}},text):
      recovered=Basic.dispose_recovery(~F.Recovery(~S),recovery)
      drained=Basic.dispose_recovery(~Maybe<&1,F.Receipt()>,receipt)
      Continue{Session{runtime,owner,held,saved,input,report ++ "restore-returned|" ++ text ++ "\n"}}
def restore(~S:Data,kind:U32,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,+saved,_,report}:
      +input=chosen(kind,saved)
      restored(~S,held,saved,input,report,Observe.raw_returned(~S,F.restore_raw(~S,owner,runtime,input)))
def publish(~S:Data,+value:U32,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,saved,input,report}:Continue{Session{Events.publish(~S,runtime,ANode{ALeaf{value},ALeaf{U32.add(value,1)}}),owner,held,saved,input,report}}
def failure_read_returned(~S:Data,owner:F.Owned(~S),local:Local.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),machine:Machine.Owned(~S),args:Array<U32>,machineArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:D.Raw,report:String,held:FR.State<Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat,result:Readers.FailureReturned(~S) & String) -> Step<S>:
  match result:
    case (Failure.Ran{runtime,failures,Failure.Succeeded{Failure.Input{_,failureArgs}}},text):Continue{Session{Mixed.failure_returned(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,held,runtime),owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "failure-read|" ++ text ++ "\n"}}
    case (Failure.Ran{runtime,failures,Failure.Rejected{failureArgs}},text):Continue{Session{Mixed.failure_returned(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,held,runtime),owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "failure-read|" ++ text ++ "\n"}}
    case (_ ,text):Stopped{report ++ "failure-read-failed|" ++ text ++ "\n"}
def failure_read_detached(~S:Data,owner:F.Owned(~S),held:Held.Owners<S>,saved:Graph.Snapshot,input:D.Raw,report:String,result:Failure.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)> & (FR.State<Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat)) -> Step<S>:
  match held result:
    case Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},(runtime,metadata):failure_read_returned(~S,owner,local,reader,registry,machine,args,machineArgs,service,foreign,foreignHandle,handles,saved,input,report,metadata,Observe.failure_returned(~S,Readers.failure_read(~S,runtime,failures,failureArgs)))
def failure_read(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,held,saved,input,report}:failure_read_detached(~S,owner,held,saved,input,report,Mixed.failure_runtime(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,runtime))
def lifecycle_read_returned(~S:Data,owner:F.Owned(~S),local:Local.Owned(~S),failures:Readers.FailureReader(~S),machine:Machine.Owned(~S),failureArgs:Array<U32>,machineArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:D.Raw,report:String,result:Readers.Returned(~S) & String) -> Step<S>:
  match result:
    case (Route.Ran{runtime,reader,registry,Ev.Succeeded{Ev.Input{_,_,args}}},text):Continue{Session{runtime,owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "lifecycle-read|" ++ text ++ "\n"}}
    case (Route.Ran{runtime,reader,registry,Ev.Rejected{args}},text):Continue{Session{runtime,owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "lifecycle-read|" ++ text ++ "\n"}}
    case (_,text):Stopped{report ++ "lifecycle-read-failed|" ++ text ++ "\n"}
def lifecycle_read(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{runtime,owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report}:lifecycle_read_returned(~S,owner,local,failures,machine,failureArgs,machineArgs,service,foreign,foreignHandle,handles,saved,input,report,Observe.lifecycle_returned(~S,Readers.read(~S,runtime,reader,registry,args)))
def machine_read_returned(~S:Data,owner:F.Owned(~S),local:Local.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),failures:Readers.FailureReader(~S),args:Array<U32>,failureArgs:Array<U32>,service:Array<U32>,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:D.Raw,report:String,metadata:Mixed.State<S,Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat,result:Machine.Returned(~S) & String) -> Step<S>:
  match result:
    case (MachineRead.ReadSucceeded{world,machine,machineArgs,_},text):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,world,metadata),owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "machine-read|" ++ text ++ "\n"}}
    case (MachineRead.ReadRejected{world,machine,machineArgs},text):Continue{Session{Mixed.join(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,world,metadata),owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report ++ "machine-read|" ++ text ++ "\n"}}
    case (_,text):Stopped{report ++ "machine-read-failed|" ++ text ++ "\n"}
def machine_read(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,Held.Owners{local,reader,registry,failures,machine,args,failureArgs,machineArgs,service,foreign,foreignHandle,handles},saved,input,report}:machine_read_returned(~S,owner,local,reader,registry,failures,args,failureArgs,service,foreign,foreignHandle,handles,saved,input,report,(family,tick),Observe.machine_returned(~S,Machine.read(~S,machine,world,machineArgs)))
def bind(~S:Data,next:Session<S> -> Step<S>,result:Step<S>) -> Step<S>:
  match result:
    case Stopped{report}:Stopped{report}
    case Continue{session}:next(session)
def read(~S:Data,session:Session<S>) -> Step<S>:bind(~S,machine_read(~S),bind(~S,failure_read(~S),lifecycle_read(~S,session)))
def insert_mode(~S:Data,world:F.World(~S)) -> F.World(~S):Init.insert_state(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S),~F.Store(~S),~F.Events(~S),~F.mode_declaration(~S),world,2)
def step(~S:Data,operation:Operation,session:Session<S>) -> Step<S>:
  match operation:
    case Checkpoint{label}:checkpoint(~S,label,session)
    case Read{}:read(~S,session)
    case LocalRun{}:run_local(~S,session)
    case Initialize{}:transform(~S,Setup.initialized(~S),session)
    case Spawn{value,barrier}:spawn(~S,value,barrier,session)
    case Seed{}:seed_session(~S,session)
    case Pending{}:transform(~S,Setup.pending_machines(~S),session)
    case Publish{value}:publish(~S,value,session)
    case Save{}:save(~S,session)
    case Restore{kind}:restore(~S,kind,session)
    case InsertMode{}:transform(~S,insert_mode(~S),session)
def loop(~S:Data,operations:List<&2,Operation>,result:Step<S>) -> String:
  match operations result:
    case _ Stopped{report}:report
    case [] Continue{Session{_,_,_,_,_,report}}:report
    case operation <> rest Continue{session}:loop(~S,rest,step(~S,operation,session))
def operations() -> List<&2,Operation>:[Checkpoint{"registered"},Read{},Checkpoint{"activated"},Initialize{},Spawn{10,True{}},Spawn{20,True{}},Spawn{30,True{}},Seed{},Pending{},Spawn{40,False{}},Publish{1000},Publish{1100},LocalRun{},Save{},Checkpoint{"seeded"},Restore{0},Checkpoint{"raw-refused"},Restore{1},Checkpoint{"resource-refused"},Restore{7},Checkpoint{"factory-refused"},Restore{2},Checkpoint{"cycle-refused"},Restore{3},Checkpoint{"machine-refused"},Restore{4},Checkpoint{"capacity-refused"},Restore{8},Checkpoint{"unknown-relation"},Restore{9},Checkpoint{"missing-endpoint"},Restore{10},Checkpoint{"duplicate-source"},Restore{11},Checkpoint{"saved-self-link"},Restore{12},Checkpoint{"unknown-machine"},Restore{13},Checkpoint{"machine-codec"},Restore{5},LocalRun{},Save{},Checkpoint{"restored"},Read{},Checkpoint{"cleared-read"},Publish{1200},InsertMode{},Read{},Checkpoint{"reader-reused"},Restore{6},Save{},Checkpoint{"roundtrip"}]
def failure_registered(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,local:Local.Owned(~S),machine:Machine.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),metadata:FR.State<Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat,result:Readers.FailureRegistration(~S)) -> String:
  match result:
    case Failure.RegistrationFailed{_}:"failure-registration-refused\n"
    case Failure.Registered{runtime,failures}:
      +blank:Graph.Snapshot=Graph.Snapshot{Snapshot.Snapshot{1,1,[],[]},[],[]}
      loop(~S,operations(),Continue{Session{Mixed.failure_returned(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,metadata,runtime),F.owned(~S,Setup.state(~S)),Held.Owners{local,reader,registry,failures,machine,ANode{ALeaf{900},ALeaf{901}},ANode{ALeaf{910},ALeaf{911}},ANode{ALeaf{920},ALeaf{921}},ANode{ALeaf{930},ALeaf{931}},foreign,foreignHandle,[]},blank,D.Null{},""}})
def failure_registration(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,local:Local.Owned(~S),machine:Machine.Owned(~S),reader:Readers.Reader(~S),registry:Readers.Registry(~S),result:Failure.Runtime<S,F.Store(~S),F.Resources(~S),F.Events(~S)> & (FR.State<Model.Events(~S),OldEvents.FamilyOwner(~S),Array<U32>> & Nat)) -> String:
  match result:
    case (runtime,metadata):failure_registered(~S,foreign,foreignHandle,local,machine,reader,registry,metadata,Readers.failure_register(~S,runtime))
def lifecycle_registered(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,local:Local.Owned(~S),machine:Machine.Owned(~S),result:Readers.Registration(~S)) -> String:
  match result:
    case Route.RegistrationFailed{_}:"lifecycle-registration-refused\n"
    case Route.Registered{runtime,reader,registry}:failure_registration(~S,foreign,foreignHandle,local,machine,reader,registry,Mixed.failure_runtime(~S,~F.Store(~S),~F.Resources(~S),~Model.Events(~S),~OldEvents.FamilyOwner(~S),~Array<U32>,runtime))
def local_registered(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,machine:Machine.Owned(~S),result:Ordinary.Registration<F.World(~S),Local.Owned(~S),Local.Capture()>) -> String:
  match result:
    case Ordinary.Rejected{_,_}:"local-registration-refused\n"
    case Ordinary.Registered{world,local}:lifecycle_registered(~S,foreign,foreignHandle,local,machine,Readers.register(~S,Events.setup(~S,world,ANode{ALeaf{800},ALeaf{801}})))
def machine_registered(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,result:Machine.Registration(~S)) -> String:
  match result:
    case SI.RegistrationFailed{_}:"machine-registration-refused\n"
    case SI.Registered{world,machine}:local_registered(~S,foreign,foreignHandle,machine,Local.define(~S,world))
def start(~S:Data,world:F.World(~S),foreign:F.World(~S),foreignHandle:W.Handle<S>) -> String:machine_registered(~S,foreign,foreignHandle,Machine.register(~S,world))
