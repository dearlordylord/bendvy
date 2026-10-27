import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ./setup.bend as Setup
import ./observation.bend as Observe
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/execution-restore-receiver.bend as Prepare
import ../../src/ecs/restore-world.bend as Progress
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as A

type Outcome<-S:Data> is Type:
  Restored{source:R.World(~S),result:E.Resumed<S>}
  SetupRefused{source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Setup.Defined<S>}
  CreationRefused{source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,creation:WorldIO.Creation<S,Layout.columns(~S,R.Components(~S)),R.Resources(~S),Unit>}
  SaveRefused{source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,result:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  FloorRefused{source:R.World(~S)}
  TargetFloorRefused{source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,world:R.World(~S)}
def resumed(~S:Data,source:R.World(~S),result:E.Resumed<S>) -> Outcome<S>:Restored{source,result}
def defined(~S:Data,native:Bool,source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Setup.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Setup.Defined{app}:IO.bind(E.Resumed<S>,Outcome<S>,E.resume(~S,native,E.restore(~S,schema,input,app)),result => IO.pure(Outcome<S>,resumed(~S,source,result)))
    case other:IO.pure(Outcome<S>,SetupRefused{source,schema,input,other})
def target_advanced(~S:Data,native:Bool,source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:R.World(~S) & Bool) -> IO(Outcome<S>):
  match result:
    case (world,True{}):defined(~S,native,source,schema,input,Setup.setup(~S,world))
    case (world,False{}):IO.pure(Outcome<S>,TargetFloorRefused{source,schema,input,world})
def created(~S:Data,+native:Bool,source:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:WorldIO.Creation<S,Layout.columns(~S,R.Components(~S)),R.Resources(~S),Unit>) -> IO(Outcome<S>):
  match result:
    case WorldIO.Created{world}:target_advanced(~S,native,source,schema,input,Progress.advance_floor(~S,~Layout.columns(~S,R.Components(~S)),~R.Resources(~S),~Unit,Schema.initialized_world(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,world),Bool.pick(U32,native,131073,1)))
    case other:IO.pure(Outcome<S>,CreationRefused{source,schema,input,other})
def saved(~S:Data,+native:Bool,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (R.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(source,Gate.Saved{input})):IO.bind(WorldIO.Creation<S,Layout.columns(~S,R.Components(~S)),R.Resources(~S),Unit>,Outcome<S>,WorldIO.create(~S,~Layout.columns(~S,R.Components(~S)),~R.Resources(~S),~Unit,~O.empty(~S),O.initial_resources(~S)),result => created(~S,native,source,schema,input,result))
    case (schema,(source,result)):IO.pure(Outcome<S>,SaveRefused{source,schema,result})
def advanced(~S:Data,native:Bool,result:R.World(~S) & Bool) -> IO(Outcome<S>):
  match result:
    case (source,True{}):saved(~S,native,Save.save(~S,~O.components(~S),~O.resources(~S),~Unit,O.schema(~S),source))
    case (source,False{}):IO.pure(Outcome<S>,FloorRefused{source})
# A real source allocator advances before save. Restore receives a separately
# created namespace and retains its own actual registered owners and Reader.
def run(~S:Data,+native:Bool,source:R.World(~S)) -> IO(Outcome<S>):advanced(~S,native,Progress.advance_floor(~S,~Layout.columns(~S,R.Components(~S)),~R.Resources(~S),~Unit,source,4))
def receiver_world(~S:Data,world:R.World(~S)) -> String:
  match world:
    case W.World{namespace,A.Allocator{next,high,_,capacity,_,free,order},_,Product.Owner{Layout.ResourceSlot{Layout.Viewed{O.Config{enabled,limit},_},_},Layout.ResourceSlot{Layout.Viewed{O.Scratch{temporary},_},_}},_,_,registrations,nextSystem,_,_}:"ns=" ++ U32.show(namespace) ++ "/next=" ++ U32.show(next) ++ "/high=" ++ U32.show(high) ++ "/capacity=" ++ U32.show(capacity) ++ "/config=" ++ Bool.show(enabled) ++ ":" ++ Observe.captured(Array.get(U32,limit,0)) ++ "/temporary=" ++ Observe.captured(Array.get(U32,temporary,0)) ++ "/registrations=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations)) ++ "/nextSystem=" ++ U32.show(nextSystem)
def captures(~S:Data,owners:Product.Owner<E.Left(~S),E.Right(~S)>,handler:E.Handler) -> String:
  match owners handler:
    case Product.Owner{Sys.Owner{_,_,_,_,_,E.Local{left,leftRuns}},Sys.Owner{_,_,_,_,_,E.ReaderLocal{right,rightRuns,Notice.Reader{namespace,id,cursor},notices}}}, E.Handler{capture,handled}:"captures=" ++ Observe.captured(Array.get(U32,left,0)) ++ "," ++ Observe.captured(Array.get(U32,right,0)) ++ "," ++ Observe.captured(Array.get(U32,capture,0)) ++ "/runs=" ++ U32.show(leftRuns) ++ "," ++ U32.show(rightRuns) ++ "/reader=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor)
def retained(~S:Data,app:E.Application(~S),receipt:Receipt.Receipt<S>) -> String:
  match app receipt:
    case Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,rules,deferred}, Receipt.Receipt{Stage.State{schema,_,_},input,_,_,_,_,_,_,Receipt.ReceiverRefused{Prepare.Capacity{}}}:"capacity-refused/input=" ++ Observe.snapshot(~S,input) ++ "/receiver=" ++ receiver_world(~S,world) ++ "/" ++ captures(~S,owners,handler)
    case _, _:"restore-retained"
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Restored{_,E.Resumed{app,receipt,report}}:Observe.resumed(~S,E.Resumed{app,receipt,report})
    case Restored{_,E.Retained{app,receipt}}:retained(~S,app,receipt)
    case _:"source-or-receiver-refused"
