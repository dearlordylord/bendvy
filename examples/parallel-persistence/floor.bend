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
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Restored{source,result}:"source=" ++ Observe.world(~S,source) ++ "/result=" ++ Observe.resumed(~S,result)
    case SetupRefused{source,schema,input,result}:"setup-refused/source=" ++ Observe.world(~S,source) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/result=" ++ Observe.setup(~S,result)
    case CreationRefused{source,schema,input,WorldIO.Created{world}}:"creation-returned-world/source=" ++ Observe.world(~S,source) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/target=" ++ Observe.world(~S,world)
    case CreationRefused{source,schema,input,WorldIO.Refused{resource}}:"creation-refused/source=" ++ Observe.world(~S,source) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/resource=" ++ Observe.resources(~S,resource)
    case SaveRefused{source,schema,result}:"save-refused/source=" ++ Observe.world(~S,source) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/result=" ++ Observe.save_result(~S,result)
    case FloorRefused{source}:"floor-refused/source=" ++ Observe.world(~S,source)
    case TargetFloorRefused{source,schema,input,world}:"target-floor-refused/source=" ++ Observe.world(~S,source) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/target=" ++ Observe.world(~S,world)
