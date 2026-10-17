import Base
import ../raw-boundary-v1/control.bend as Control
import ../../../src/ecs/restore-raw.bend as Raw
import core/restore-raw-owner.bend as RawOwner
import ../basic-world-statefree-v1/schema.bend as F
import ../basic-world-statefree-v1/factory.bend as Factory
import ../basic-world-statefree-v1/model.bend as Model
import ../basic-world-statefree-v1/setup.bend as Setup
import ../basic-world-statefree-v1/save.bend as Save
import ../basic-world-statefree-v1/restore.bend as Restore
import ../basic-world-statefree-v1/runtime.bend as Runtime
import ../basic-world-statefree-v1/events.bend as Event
import ../basic-world-statefree-v1/reader.bend as Reader
import ../basic-world-statefree-v1/locals.bend as Locals
import ../basic-world-statefree-v1/observe.bend as O
import ../basic-world-statefree-v1/inspect.bend as Inspect
import ../basic-world-statefree-v1/catalog.bend as Catalog
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/snapshot-data.bend as Snapshot
import ../../../src/ecs/decode-data.bend as D
import ../../../src/ecs/restore-data.bend as R
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/ordinary-app-local-fields.bend as OrdinaryLocal
import ../../../src/ecs/local.bend as Local
import ../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T

type Session<S:Data> is Type:
  Session{runtime:Event.Runtime(~S),owner:F.Owned(~S),local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String}
def checkpoint_join(~S:Data,label:String,+old:List<&2,W.Handle<S>>,+other:List<&2,W.Handle<S>>,+saved:Snapshot.Snapshot,text:String,a:Event.Runtime(~S) & String,b:F.Owned(~S) & String,c:Locals.Owned(~S) & String,d:Reader.ReaderOwner(~S) & String,e:Reader.Registry(~S) & String,f:Maybe<&1,Array<U32>> & String,g:F.World(~S) & String) -> Session<S>:
  (runtime,rt)=a
  (owner,ow)=b
  (local,lo)=c
  (reader,rd)=d
  (registry,rg)=e
  (args,ar)=f
  (foreign,fw)=g
  Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text ++ label ++ ":" ++ rt ++ ";" ++ ow ++ ";" ++ lo ++ ";" ++ rd ++ ";" ++ rg ++ ";args=" ++ ar ++ ";foreign=" ++ fw ++ ";old=" ++ List.show(&2,W.Handle<S>,O.handle(~S),old) ++ ";other=" ++ List.show(&2,W.Handle<S>,O.handle(~S),other) ++ ";saved=" ++ O.snapshot(saved) ++ "\n"}

def checkpoint(~S:Data,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text}:checkpoint_join(~S,label,old,other,saved,text,Inspect.runtime(~S,runtime),O.owner(~S,owner),O.local(~S,local),Inspect.reader(~S,reader),Inspect.registry(~S,registry),O.optional(~Array<U32>,~O.u32_array,args),O.world(~S,foreign))

def modified(+invalid:Bool,value:Snapshot.Snapshot) -> Snapshot.Snapshot:
  match invalid value:
    case False{},Snapshot.Snapshot{version,_,entities,resources}:Snapshot.Snapshot{version,8,entities,resources}
    case True{},Snapshot.Snapshot{version,_,entities,_}:Snapshot.Snapshot{version,8,entities,[D.Field{"Settings",D.Text{"late-resource-failure"}}]}

def restore_receipts(~S:Data,label:String,runtime:Event.Runtime(~S),owner:F.Owned(~S),local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,recovered:F.FullRecovery(~S) & String,drained:Maybe<&1,Catalog.DrainReceipt()> & String) -> Session<S>:
  (receipt,recoveryText)=recovered
  (drainReceipt,drainText)=drained
  checkpoint(~S,label,Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text ++ "recovery:" ++ recoveryText ++ ";drained=" ++ drainText ++ "\n"})

def restore_join(~S:Data,label:String,local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:Restore.Restored(~S)) -> Session<S>:
  match observed:
    case (runtime,(owner,(outcome,(recovery,drained)))):restore_receipts(~S,label,runtime,owner,local,reader,registry,args,foreign,old,other,saved,text ++ "outcome:" ++ Inspect.outcome(~S,outcome) ++ "\n",O.recovery(~S,recovery),Inspect.drain(drained))

def raw_join(~S:Data,label:String,local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,result:RawOwner.Returned<F.Owned(~S),Event.Runtime(~S),Restore.Restored(~S)>) -> Session<S>:
  match result:
    case RawOwner.ParseRejected{owner,runtime,original,error}:checkpoint(~S,label,Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text ++ "raw-rejected:" ++ Control.error(error) ++ ";original=" ++ Control.raw(original) ++ "\n"})
    case RawOwner.Delivered{original,returned}:restore_join(~S,label,local,reader,registry,args,foreign,old,other,saved,text ++ "raw-delivered:" ++ Control.raw(original) ++ "\n",returned)
def restore_raw(~S:Data,label:String,input:D.Raw,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text}:raw_join(~S,label,local,reader,registry,args,foreign,old,other,saved,text,RawOwner.run(~F.Owned(~S),~Event.Runtime(~S),~Restore.Restored(~S),~Restore.restore(~S),owner,runtime,input))
def restore(~S:Data,invalid:Bool,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,+saved,text}:raw_join(~S,label,local,reader,registry,args,foreign,old,other,saved,text,RawOwner.run(~F.Owned(~S),~Event.Runtime(~S),~Restore.Restored(~S),~Restore.restore(~S),owner,runtime,Raw.encode(modified(invalid,saved))))

def read_failure(value:Core.Failure<Unit>) -> String:
  match value:
    case Core.MissingPayload{}:"MissingPayload"
    case Core.BodyFailed{Unit{}}:"BodyFailed"

def read_outcome(value:T.Outcome<Core.Failure<Unit>>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{failure}:read_failure(failure)

def read_join(~S:Data,label:String,owner:F.Owned(~S),local:Locals.Owned(~S),foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:Reader.ReadResult(~S)) -> Session<S>:
  match observed:
    case Route.Ran{runtime,reader,registry,Ev.Succeeded{Core.Reply{outcome,args,lagged}}}:checkpoint(~S,label,Session{runtime,owner,local,reader,registry,Some{args},foreign,old,other,saved,text ++ "reading:" ++ read_outcome(outcome) ++ ";lagged=" ++ Bool.show(lagged) ++ "\n"})
    case Route.Ran{runtime,reader,registry,Ev.Rejected{args}}:checkpoint(~S,label,Session{runtime,owner,local,reader,registry,Some{args},foreign,old,other,saved,text ++ "reading:RegistrationRejected\n"})
    case Route.Ran{runtime,reader,registry,Ev.Failed{Unit{}}}:checkpoint(~S,label,Session{runtime,owner,local,reader,registry,None{},foreign,old,other,saved,text ++ "reading:TransportFailed\n"})

def read(~S:Data,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,Some{args},foreign,old,other,saved,text}:read_join(~S,label,owner,local,foreign,old,other,saved,text,Runtime.read(~S,runtime,reader,registry,args))
    case Session{runtime,owner,local,reader,registry,None{},foreign,old,other,saved,text}:checkpoint(~S,label,Session{runtime,owner,local,reader,registry,None{},foreign,old,other,saved,text ++ "reading:NoReturnedArgs\n"})

def publish(~S:Data,label:String,+value:U32,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text}:checkpoint(~S,label,Session{Runtime.publish(~S,runtime,ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}),owner,local,reader,registry,args,foreign,old,other,saved,text})

def local_result(result:Result<&2,&1,Unit,U32>) -> String:
  match result:
    case Done{value}:"Done(" ++ U32.show(value) ++ ")"
    case Fail{Unit{}}:"Fail"

def local_returned(~S:Data,label:String,family:Event.State(~S),tick:Nat,owner:F.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:Local.Run<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),Locals.Capture(),Unit,Unit,U32,OrdinaryLocal.runner(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Locals.Capture(),~Unit,~Unit,~U32,~Locals.Ops,~Locals.declaration(~S),~Locals.body)>) -> Session<S>:
  match observed:
    case Local.Completed{world,instance,result}:checkpoint(~S,label,Session{Route.Runtime{world,family,tick},owner,OrdinaryLocal.Owner{instance},reader,registry,args,foreign,old,other,saved,text ++ "local:" ++ local_result(result) ++ "\n"})
    case Local.Refused{world,instance,Unit{}}:checkpoint(~S,label,Session{Route.Runtime{world,family,tick},owner,OrdinaryLocal.Owner{instance},reader,registry,args,foreign,old,other,saved,text ++ "local:Refused\n"})

def run_local(~S:Data,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,local,reader,registry,args,foreign,old,other,saved,text}:local_returned(~S,label,family,tick,owner,reader,registry,args,foreign,old,other,saved,text,OrdinaryLocal.run(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Locals.Capture(),~Unit,~Unit,~U32,~Locals.Ops,~Locals.declaration(~S),~Locals.body,local,world,Unit{}))

def checked_tail(~S:Data,value:Bool,observed:F.World(~S) & String) -> F.World(~S) & String:
  match observed:
    case (world,text):(world,Bool.show(value) ++ "," ++ text)

def checked_one(~S:Data,next:F.World(~S) -> F.World(~S) & String,observed:F.World(~S) & Bool) -> F.World(~S) & String:
  match observed:
    case (world,value):checked_tail(~S,value,next(world))

def checked(~S:Data,handles:List<&2,W.Handle<S>>,world:F.World(~S)) -> F.World(~S) & String:
  match handles:
    case []:(world,"")
    case handle <> rest:checked_one(~S,next => checked(~S,rest,next),W.valid(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),world,handle))

def validate_join(~S:Data,family:Event.State(~S),tick:Nat,owner:F.Owned(~S),local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:F.World(~S) & String) -> Session<S>:
  match observed:
    case (world,valid):checkpoint(~S,"old-and-foreign",Session{Route.Runtime{world,family,tick},owner,local,reader,registry,args,foreign,old,other,saved,text ++ "valid:" ++ valid ++ "\n"})

def validate(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,local,reader,registry,args,foreign,+old,+other,saved,text}:validate_join(~S,family,tick,owner,local,reader,registry,args,foreign,old,other,saved,text,checked(~S,List.append(&2,W.Handle<S>,old,other),world))

def omitted(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,Snapshot.Snapshot{+version,next,+entities,+resources},text}:raw_join(~S,"omitted-resource",local,reader,registry,args,foreign,old,other,Snapshot.Snapshot{version,next,entities,resources},text,RawOwner.run(~F.Owned(~S),~Event.Runtime(~S),~Restore.Restored(~S),~Restore.restore(~S),owner,runtime,Raw.encode(Snapshot.Snapshot{version,8,entities,[]})))
def later_join(~S:Data,family:Event.State(~S),tick:Nat,owner:F.Owned(~S),local:Locals.Owned(~S),reader:Reader.ReaderOwner(~S),registry:Reader.Registry(~S),args:Maybe<&1,Array<U32>>,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:F.World(~S) & W.Reservation<S>) -> Session<S>:
  match observed:
    case (world,reservation):checkpoint(~S,"later-spawn",Session{Route.Runtime{world,family,tick},owner,local,reader,registry,args,foreign,old,other,saved,text ++ "later:" ++ Inspect.reservation(~S,reservation) ++ "\n"})
def later(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{Route.Runtime{world,family,tick},owner,local,reader,registry,args,foreign,old,other,saved,text}:later_join(~S,family,tick,owner,local,reader,registry,args,foreign,old,other,saved,text,Setup.spawn(~S,world,910,True{}))
def malformed(~S:Data,session:Session<S>) -> Session<S>:
  restore_raw(~S,"malformed-components",Control.envelope(D.Number{1},D.Number{8},D.Array{[Control.entity(D.Text{"wrong-components"})]},D.Null{}),restore_raw(~S,"malformed-entity",Control.envelope(D.Number{1},D.Number{8},D.Array{[D.Text{"wrong-entity"}]},D.Null{}),session))
def finish(~S:Data,session:Session<S>) -> String:
  match session:
    case Session{runtime,owner,local,reader,registry,args,foreign,old,other,saved,text}:text

def original_execute(~S:Data,session:Session<S>) -> Session<S>:run_local(~S,"local-after",read(~S,"new-event-read",publish(~S,"new-event",888,read(~S,"old-event-cleared",validate(~S,restore(~S,False{},"restore-success",restore(~S,True{},"late-refusal",run_local(~S,"local-before",publish(~S,"unread-backlog",777,read(~S,"reader-activated",malformed(~S,checkpoint(~S,"initial",session))))))))))))
def execute(~S:Data,session:Session<S>) -> String:finish(~S,later(~S,omitted(~S,original_execute(~S,session))))

def failed_world(~S:Data,label:String,a:F.World(~S) & String,b:F.World(~S) & String,extra:String) -> String:
  (world,first)=a
  (foreign,second)=b
  label ++ ":" ++ first ++ ";foreign=" ++ second ++ ";" ++ extra

def failed_reader(~S:Data,text:String,a:Event.Runtime(~S) & String,b:Locals.Owned(~S) & String,c:F.World(~S) & String) -> String:
  (runtime,rt)=a
  (local,lo)=b
  (foreign,fw)=c
  text ++ "readerRegistrationFailed:" ++ rt ++ ";" ++ lo ++ ";foreign=" ++ fw

def registered_reader(~S:Data,local:Locals.Owned(~S),foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:Reader.Registration(~S)) -> String:
  match observed:
    case Route.Registered{runtime,reader,registry}:execute(~S,Session{runtime,F.initial(~S),local,reader,registry,Some{ANode{ALeaf{0},ALeaf{777}}},foreign,old,other,saved,text})
    case Route.RegistrationFailed{runtime}:failed_reader(~S,text,Inspect.runtime(~S,runtime),O.local(~S,local),O.world(~S,foreign))

def failed_local(~S:Data,text:String,a:F.World(~S) & String,b:F.World(~S) & String,c:Locals.Capture() & String) -> String:
  (capture,cap)=c
  failed_world(~S,text ++ "localRegistrationFailed",a,b,cap)

def registered_local(~S:Data,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:OrdinaryLocal.Registration<F.World(~S),Locals.Owned(~S),Locals.Capture()>) -> String:
  match observed:
    case OrdinaryLocal.Registered{world,owner}:registered_reader(~S,owner,foreign,old,other,saved,text,Runtime.register(~S,Runtime.setup(~S,world,ANode{ALeaf{800},ALeaf{801}})))
    case OrdinaryLocal.Rejected{world,capture}:failed_local(~S,text,O.world(~S,world),O.world(~S,foreign),O.product(~Array<U32>,~Array<U32>,~O.u32_array,~O.u32_array,capture))

def pending(~S:Data,foreign:F.World(~S),old:List<&2,W.Handle<S>>,other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:F.World(~S) & W.Reservation<S>) -> String:
  match observed:
    case (world,reservation):registered_local(~S,foreign,old,other,saved,text ++ "pending:" ++ Inspect.reservation(~S,reservation) ++ "\n",Locals.define(~S,world))

def old_handles(~S:Data,foreign:F.World(~S),other:List<&2,W.Handle<S>>,saved:Snapshot.Snapshot,text:String,observed:F.World(~S) & List<&2,W.Handle<S>>) -> String:
  match observed:
    case (world,old):pending(~S,foreign,old,other,saved,text,Setup.spawn(~S,world,50,False{}))

def saved(~S:Data,foreign:F.World(~S),other:List<&2,W.Handle<S>>,text:String,observed:F.World(~S) & Snapshot.Snapshot) -> String:
  match observed:
    case (world,+snapshot):old_handles(~S,foreign,other,snapshot,text ++ "saved:" ++ O.snapshot(snapshot) ++ "\n",W.handles(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),world))

def second(~S:Data,foreign:F.World(~S),other:List<&2,W.Handle<S>>,text:String,observed:F.World(~S) & W.Reservation<S>) -> String:
  match observed:
    case (world,reservation):saved(~S,foreign,other,text ++ "spawn2:" ++ Inspect.reservation(~S,reservation) ++ "\n",Save.save(~S,world))

def first(~S:Data,foreign:F.World(~S),other:List<&2,W.Handle<S>>,text:String,observed:F.World(~S) & W.Reservation<S>) -> String:
  match observed:
    case (world,reservation):second(~S,foreign,other,text ++ "spawn1:" ++ Inspect.reservation(~S,reservation) ++ "\n",Setup.spawn(~S,world,20,True{}))

def foreign_handles(~S:Data,world:F.World(~S),text:String,observed:F.World(~S) & List<&2,W.Handle<S>>) -> String:
  match observed:
    case (foreign,other):first(~S,foreign,other,text,Setup.spawn(~S,world,10,True{}))

def foreign_spawn(~S:Data,world:F.World(~S),observed:F.World(~S) & W.Reservation<S>) -> String:
  match observed:
    case (foreign,reservation):foreign_handles(~S,world,"foreignSpawn:" ++ Inspect.reservation(~S,reservation) ++ "\n",W.handles(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),foreign))

def run(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:foreign_spawn(~S,world,Setup.spawn(~S,foreign,70,True{}))
