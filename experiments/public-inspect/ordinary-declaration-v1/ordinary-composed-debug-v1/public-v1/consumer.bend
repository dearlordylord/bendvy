import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import state.bend as F
import bindings.bend as B
import application.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import physical.bend as Physical
import event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FR
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Pub
type Checkpoint is Data:
  Checkpoint{description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,dump:Maybe<&2,Dump.Dump<F.S>>,fields:List<&2,Records.Fields<F.S>>,physical:String}
type Report is Data:
  Report{factory:U32,checkpoints:List<&2,Checkpoint>,run:A.RunDescription}
def physical_returned(description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,dump:Maybe<&2,Dump.Dump<F.S>>,fields:List<&2,Records.Fields<F.S>>,schema:Schema.Schema<F.S,F.Store,F.Resources>,owners:B.Owners4(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:Events.Runtime() & String) -> A.Application() & Checkpoint:
  match result:
    case (runtime,text):(Family.Application{schema,runtime,owners,recipe,debug},Checkpoint{description,inventory,dump,fields,text})
def folded(description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,dump:Maybe<&2,Dump.Dump<F.S>>,schema:Schema.Schema<F.S,F.Store,F.Resources>,runtime:Events.Runtime(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:B.Owners4() & List<&2,Records.Fields<F.S>>) -> A.Application() & Checkpoint:
  match result:
    case (owners,fields):physical_returned(description,inventory,dump,fields,schema,owners,recipe,debug,Physical.runtime(runtime))
def dumped(description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,inventory:Maybe<&2,List<&2,String>>,result:A.Application() & Maybe<&2,Dump.Dump<F.S>>) -> A.Application() & Checkpoint:
  match result:
    case (Family.Application{schema,runtime,owners,recipe,debug},dump):folded(description,inventory,dump,schema,runtime,recipe,debug,B.fold4()(owners))
def inventoried(description:Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>,result:A.Application() & Maybe<&2,List<&2,String>>) -> A.Application() & Checkpoint:
  match result:
    case (app,inventory):dumped(description,inventory,A.dump(app))
def described(result:A.Application() & Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>) -> A.Application() & Checkpoint:
  match result:
    case (app,description):inventoried(description,A.inventory(app))
def checkpoint(value:A.Application(),flag:Bool) -> A.Application() & Checkpoint:described(A.snapshot(A.enabled(value,flag)))
def final(factory:U32,before:List<&2,Checkpoint>,run:A.RunDescription,result:A.Application() & Checkpoint) -> Report:
  match result:
    case (_,view):Report{factory,List.append(&2,Checkpoint,before,[view]),run}
def executed(factory:U32,before:List<&2,Checkpoint>,result:A.Application() & A.RunDescription) -> Report:
  match result:
    case (app,run):final(factory,before,run,checkpoint(app,True{}))
def disabled(factory:U32,before:List<&2,Checkpoint>,result:A.Application() & Checkpoint) -> Report:
  match result:
    case (app,view):executed(factory,List.append(&2,Checkpoint,before,[view]),A.run(app))
def repeated(factory:U32,before:List<&2,Checkpoint>,result:A.Application() & Checkpoint) -> Report:
  match result:
    case (app,view):disabled(factory,List.append(&2,Checkpoint,before,[view]),checkpoint(app,False{}))
def enabled(factory:U32,before:List<&2,Checkpoint>,result:A.Application() & Checkpoint) -> Report:
  match result:
    case (app,view):repeated(factory,List.append(&2,Checkpoint,before,[view]),checkpoint(app,True{}))
def constructed(factory:U32,result:A.Construction) -> Maybe<&2,Report>:
  match result:
    case A.Ready{app}:Some{enabled(factory,[],checkpoint(A.publish(app),True{}))}
    case A.ServiceRejected{_}:None{}
    case A.ComponentRejected{_}:None{}
    case A.ResourceRejected{_}:None{}
def swapped_first(rest:F.Rest,result:Col.SwapOutcome<F.S,Array<U32>>) -> F.Store:
  match result:
    case Col.Accepted{column,_}:F.first_put(rest,column)
    case Col.Rejected{column,_}:F.first_put(rest,column)
def seed_first(store:F.Store,+id:U32,value:U32) -> F.Store:
  match store:
    case F.Store{a,b,c}:swapped_first(F.Rest{b,c},Col.swap(~F.S,~Array<U32>,Col.ensure(~F.S,~Array<U32>,a,id),id,Some{ALeaf{value}}))
def swapped_second(rest:F.Rest,result:Col.SwapOutcome<F.S,Array<U32>>) -> F.Store:
  match result:
    case Col.Accepted{column,_}:F.second_put(rest,column)
    case Col.Rejected{column,_}:F.second_put(rest,column)
def seed_second(store:F.Store,+id:U32,value:U32) -> F.Store:
  match store:
    case F.Store{a,b,c}:swapped_second(F.Rest{a,c},Col.swap(~F.S,~Array<U32>,Col.ensure(~F.S,~Array<U32>,b,id),id,Some{ALeaf{value}}))
def seed(store:F.Store) -> F.Store & Unit:(seed_second(seed_second(seed_first(seed_first(store,1,11),3,33),2,22),4,44),Unit{})
def barrier(world:F.World()) -> F.World():
  match world:
    case W.World{ns,id,high,live,cap,depth,store,F.Resources{clock,mode,inventory,sibling,count},events,pending,regs,sys,tick}:W.World{ns,id,high,live,cap,depth,store,F.Resources{clock,mode,inventory,sibling,(count+1:U32)},events,pending,regs,sys,tick}
def seeded(factory:U32,result:F.World() & Unit) -> Maybe<&2,Report>:
  match result:
    case (world,_):constructed(factory,A.construct(W.enqueue(~F.S,~F.Store,~F.Resources,~F.Events(),world,barrier)))
def activated(factory:U32,result:F.World() & W.Status) -> Maybe<&2,Report>:
  match result:
    case (world,_):seeded(factory,W.with_store(~F.S,~F.Store,~F.Resources,~F.Events(),~Unit,seed,world))
def reserved4(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,_):activated(factory,(world,W.Accepted{}))
def third_deactivated(factory:U32,result:F.World() & W.Status) -> Maybe<&2,Report>:
  match result:
    case (world,_):reserved4(factory,W.reserve_id(~F.S,~F.Store,~F.Resources,~F.Events(),world))
def third_activated(factory:U32,handle:W.Handle<F.S>,result:F.World() & W.Status) -> Maybe<&2,Report>:
  match result:
    case (world,_):third_deactivated(factory,W.deactivate(~F.S,~F.Store,~F.Resources,~F.Events(),world,handle))
def reserved3(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,W.Reserved{+handle}):third_activated(factory,handle,W.activate(~F.S,~F.Store,~F.Resources,~F.Events(),world,handle))
    case (world,W.ReservationRejected{_}):third_deactivated(factory,(world,W.Accepted{}))
def second_activated(factory:U32,result:F.World() & W.Status) -> Maybe<&2,Report>:
  match result:
    case (world,_):reserved3(factory,W.reserve_id(~F.S,~F.Store,~F.Resources,~F.Events(),world))
def reserved2(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,W.Reserved{handle}):second_activated(factory,W.activate(~F.S,~F.Store,~F.Resources,~F.Events(),world,handle))
    case (world,W.ReservationRejected{_}):second_activated(factory,(world,W.Accepted{}))
def first_activated(factory:U32,result:F.World() & W.Status) -> Maybe<&2,Report>:
  match result:
    case (world,_):reserved2(factory,W.reserve_id(~F.S,~F.Store,~F.Resources,~F.Events(),world))
def reserved1(factory:U32,result:F.World() & W.Reservation<F.S>) -> Maybe<&2,Report>:
  match result:
    case (world,W.Reserved{handle}):first_activated(factory,W.activate(~F.S,~F.Store,~F.Resources,~F.Events(),world,handle))
    case (world,W.ReservationRejected{_}):first_activated(factory,(world,W.Accepted{}))
def created(result:W.Creation<F.S,F.Store,F.Resources,F.Events()>) -> Maybe<&2,Report>:
  match result:
    case W.Created{W.Factory{factory},world}:reserved1(factory,W.reserve_id(~F.S,~F.Store,~F.Resources,~F.Events(),world))
    case W.CreateRejected{_,_}:None{}
def run() -> Maybe<&2,Report>:created(W.create(~F.S,~F.Store,~F.Resources,~F.Events(),~F.empty,W.factory(),F.initial_resources()))
