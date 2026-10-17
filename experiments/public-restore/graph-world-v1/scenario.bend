import Base
import ../../../src/ecs/entity-key-render.bend as KeyText
import ./fixture.bend as F
import ./setup.bend as Setup
import ./reader.bend as Reader
import ./input.bend as Input
import ./observe.bend as Observe
import ../basic-world-statefree-v1/observe.bend as O
import ../../../src/ecs/restore-graph-data.bend as Graph
import ../../../src/ecs/restore-graph-public.bend as Restore
import ../../../src/ecs/restore-public.bend as Basic
import ../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/ordinary-machine-transition-reader.bend as Read
import ../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../src/ecs/relation-commands.bend as Relation
import ../../../src/ecs/relation-failure-reader.bend as Decl
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/system-instance.bend as SI

type Session<S:Data> is Type:
  Session{world:F.World(~S),foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String}
type Step<S:Data> is Type:Continue{session:Session<S>} Stopped{report:String}
type Operation is Data:
  Checkpoint{label:String}
  Read{}
  Initialize{}
  Spawn{value:U32,barrier:Bool}
  SeedRelations{}
  PendingMachines{}
  ForeignRelate{}
  Save{}
  Restore{kind:U32}
  InsertMode{}
def scalar(value:U32) -> U32 & String:
  +copy=value
  (copy,U32.show(copy))
def binding(~S:Data,value:R.Binding<S>) -> String:
  match value:
    case R.Binding{saved,target}:KeyText.show(saved) ++ "->" ++ O.handle(~S,target)
def bindings(~S:Data,values:List<&2,R.Binding<S>>) -> String:List.show(&2,R.Binding<S>,binding(~S),values)
def checkpoint_joined(~S:Data,label:String,+foreignHandle:W.Handle<S>,+handles:List<&2,W.Handle<S>>,+saved:Graph.Snapshot,+input:Graph.Snapshot,+mappings:List<&2,List<&2,R.Binding<S>>>,report:String,w:F.World(~S) & String,f:F.World(~S) & String,o:F.Owned(~S) & String,r:Reader.Owned(~S) & String,a:Array<U32> & String) -> Step<S>:
  match w f o r a:
    case (world,worldText),(foreign,foreignText),(owner,ownerText),(reader,readerText),(args,argsText):Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ label ++ "|world=" ++ worldText ++ "|foreign=" ++ foreignText ++ "|foreignHandle=" ++ O.handle(~S,foreignHandle) ++ "|owner=" ++ ownerText ++ "|reader=" ++ readerText ++ "|args=" ++ argsText ++ "|handles=" ++ List.show(&2,W.Handle<S>,O.handle(~S),handles) ++ "|saved=" ++ Observe.snapshot(saved) ++ "|input=" ++ Observe.snapshot(input) ++ "|maps=" ++ List.show(&2,List<&2,R.Binding<S>>,bindings(~S),mappings) ++ "\n"}}
def checkpoint(~S:Data,label:String,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}:checkpoint_joined(~S,label,foreignHandle,handles,saved,input,mappings,report,Observe.world(~S,world),Observe.world(~S,foreign),Observe.owner(~S,owner),Observe.reader(~S,reader),O.array(~U32,~scalar,args))
def restored(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:F.Returned(~S) & String) -> Step<S>:
  match result:
    case (Restore.Restored{world,owner,recovery,newBindings},text):
      unit=Basic.dispose_recovery(~F.Recovery(~S),recovery)
      Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,List.append(&2,List<&2,R.Binding<S>>,mappings,[newBindings]),report ++ "restore-returned|" ++ text ++ "\n"}}
    case (Restore.Rejected{world,owner,recovery,_,_},text):
      unit=Basic.dispose_recovery(~F.Recovery(~S),recovery)
      Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ "restore-returned|" ++ text ++ "\n"}}
    case (Restore.MissingBinding{world,owner,recovery,_},text):Stopped{report ++ "invariant-failure|" ++ text ++ "\n"}
def chosen(kind:U32,saved:Graph.Snapshot) -> Graph.Snapshot:
  match kind:
    case 0:Input.cycle(Input.patched(saved,1))
    case 1:Input.patched(saved,9)
    case 2:Input.patched(saved,1)
    case _:saved
def restore(~S:Data,kind:U32,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,+saved,_,mappings,report}:
      +input=chosen(kind,saved)
      restored(~S,foreign,foreignHandle,reader,args,handles,saved,input,mappings,report,Observe.returned(~S,F.restore(~S,owner,world,input)))
def saved(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:F.World(~S) & Graph.Snapshot) -> Step<S>:
  match result:
    case (world,+snapshot):Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,snapshot,input,mappings,report ++ "save-returned|" ++ Observe.snapshot(snapshot) ++ "\n"}}
def save(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,_,input,mappings,report}:saved(~S,foreign,foreignHandle,owner,reader,args,handles,input,mappings,report,F.save(~S,world))
def read_returned(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:Reader.Returned(~S) & String) -> Step<S>:
  match result:
    case (Read.ReadSucceeded{world,reader,args,_},text):Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ "read-returned|" ++ text ++ "\n"}}
    case (Read.ReadRejected{world,reader,args},text):Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ "read-returned|" ++ text ++ "\n"}}
    case (Read.ReadFailed{_,_,_,_},text):Stopped{report ++ "read-failed|" ++ text ++ "\n"}
def read(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}:read_returned(~S,foreign,foreignHandle,owner,handles,saved,input,mappings,report,Observe.read_returned(~S,Reader.read(~S,reader,world,args)))
def spawned(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:F.World(~S) & W.Reservation<S>) -> Step<S>:
  match result:
    case (world,W.Reserved{handle}):Continue{Session{world,foreign,foreignHandle,owner,reader,args,List.append(&2,W.Handle<S>,handles,[handle]),saved,input,mappings,report}}
    case (world,W.ReservationRejected{_}):Stopped{report ++ "spawn-refused\n"}
def spawn(~S:Data,value:U32,barrier:Bool,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}:spawned(~S,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report,Setup.spawn(~S,world,value,barrier))
def seed(~S:Data,world:F.World(~S),handles:List<&2,W.Handle<S>>) -> F.World(~S):
  match handles:
    case +first <> +second <> +third <> _:W.barrier(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,Setup.relate(~S,world,F.link(~S),third,second),F.link(~S),first,second),F.parent(~S),third,first),F.parent(~S),first,second),F.link(~S),first,first))
    case _:world
def transform(~S:Data,change:F.World(~S) -> F.World(~S),session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}:Continue{Session{change(world),foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}}
def seed_session(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,foreignHandle,owner,reader,args,+handles,saved,input,mappings,report}:Continue{Session{seed(~S,world,handles),foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report}}
def queue_text(value:Relation.QueueStatus) -> String:
  match value:
    case Relation.Queued{}:"Queued"
    case Relation.MissingEntity{}:"MissingEntity"
def foreign_finished(~S:Data,status:Relation.QueueStatus,foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:T.Returned<F.World(~S),Unit>) -> Step<S>:
  match result:
    case T.Returned{world,T.Success{}}:Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ "foreign-queue|" ++ queue_text(status) ++ "|Success\n"}}
    case T.Returned{world,T.Failure{_}}:Continue{Session{world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report ++ "foreign-queue|" ++ queue_text(status) ++ "|Failure\n"}}
def foreign_queued(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,result:T.Tx<F.World(~S),F.Events(~S)> & Relation.QueueStatus) -> Step<S>:
  match result:
    case (tx,status):foreign_finished(~S,status,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report,Cmd.tx_finish(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Unit,tx,T.Success{}))
def foreign_descriptor(~S:Data,world:F.World(~S),foreign:F.World(~S),+foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,target:W.Handle<S>,declaration:Decl.Declaration<S>) -> Step<S>:
  match declaration:
    case Decl.Declaration{descriptor}:foreign_queued(~S,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report,Relation.queue_relate(~S,~F.Components(~S),~F.Resources(~S),~R.Change<S>,T.begin(~F.World(~S),~F.Events(~S),world),descriptor,foreignHandle,target))
def foreign_target(~S:Data,world:F.World(~S),foreign:F.World(~S),+foreignHandle:W.Handle<S>,owner:F.Owned(~S),reader:Reader.Owned(~S),args:Array<U32>,handles:List<&2,W.Handle<S>>,saved:Graph.Snapshot,input:Graph.Snapshot,mappings:List<&2,List<&2,R.Binding<S>>>,report:String,values:List<&2,W.Handle<S>>) -> Step<S>:
  match values:
    case []:Stopped{report ++ "missing-primary-handle\n"}
    case target <> _:foreign_descriptor(~S,world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report,target,F.link(~S))
def foreign_session(~S:Data,session:Session<S>) -> Step<S>:
  match session:
    case Session{world,foreign,+foreignHandle,owner,reader,args,+handles,saved,input,mappings,report}:foreign_target(~S,world,foreign,foreignHandle,owner,reader,args,handles,saved,input,mappings,report,handles)
def insert_mode(~S:Data,world:F.World(~S)) -> F.World(~S):Init.insert_state(~S,~F.Mode,~U32,~F.Resources(~S),~F.mode_take(~S),~F.mode_put(~S),~F.Store(~S),~F.Events(~S),~F.mode_declaration(~S),world,2)
def step(~S:Data,operation:Operation,session:Session<S>) -> Step<S>:
  match operation:
    case Checkpoint{label}:checkpoint(~S,label,session)
    case Read{}:read(~S,session)
    case Initialize{}:transform(~S,Setup.initialized(~S),session)
    case Spawn{value,barrier}:spawn(~S,value,barrier,session)
    case SeedRelations{}:seed_session(~S,session)
    case PendingMachines{}:transform(~S,Setup.pending_machines(~S),session)
    case ForeignRelate{}:foreign_session(~S,session)
    case Save{}:save(~S,session)
    case Restore{kind}:restore(~S,kind,session)
    case InsertMode{}:transform(~S,insert_mode(~S),session)
def loop(~S:Data,operations:List<&2,Operation>,result:Step<S>) -> String:
  match operations result:
    case _ Stopped{report}:report
    case [] Continue{Session{_,_,_,_,_,_,_,_,_,_,report}}:report
    case operation <> rest Continue{session}:loop(~S,rest,step(~S,operation,session))
def operations() -> List<&2,Operation>:
  [Checkpoint{"registered"},Read{},Checkpoint{"activated"},Initialize{},Spawn{10,True{}},Spawn{20,True{}},Spawn{30,True{}},SeedRelations{},PendingMachines{},Spawn{40,False{}},Save{},Checkpoint{"seeded"},ForeignRelate{},Checkpoint{"foreign-refused"},Restore{0},Checkpoint{"cycle-refused"},Restore{1},Checkpoint{"machine-refused"},Restore{2},Save{},Checkpoint{"restored"},Read{},Checkpoint{"cleared-read"},Restore{3},Save{},Checkpoint{"legacy-roundtrip"},InsertMode{},Read{},Checkpoint{"reader-reused"}]
def registered(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,result:Reader.Registration(~S)) -> String:
  match result:
    case SI.RegistrationFailed{world}:"registration-refused\n"
    case SI.Registered{world,reader}:
      +blank:Graph.Snapshot=Graph.Snapshot{Snapshot.Snapshot{1,1,[],[]},[],[]}
      loop(~S,operations(),Continue{Session{world,foreign,foreignHandle,F.owned(~S,Setup.state(~S)),reader,ANode{ALeaf{800},ALeaf{801}},[],blank,blank,[],""}})
def start(~S:Data,world:F.World(~S),foreign:F.World(~S),foreignHandle:W.Handle<S>) -> String:registered(~S,foreign,foreignHandle,Reader.register(~S,world))
