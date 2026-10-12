import Base
import ../alpha/state.bend as F
import ../alpha/bindings.bend as B
import ../alpha/base-application.bend as BaseApp
import ../alpha/application.bend as A
import ../alpha/consumer.bend as C
import ../alpha/event-setup.bend as Events
import ../alpha/dispatch.bend as Dispatch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-condition-schedule.bend as API
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
def width_changed(value:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>) -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:
  match value:
    case D.Program{width,build,names,evaluate}:D.Program{Nat.add(width,1n),build,names,evaluate}
def names_changed(value:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>) -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:
  match value:
    case D.Program{width,build,_,evaluate}:D.Program{width,build,[],evaluate}
def slots_changed(value:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>) -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:
  match value:
    case D.Program{width,build,names,evaluate}:D.Program{width,ids => D.shifted(~F.S,build(ids),99),names,evaluate}
def bad_width() -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:width_changed(A.program())
def bad_names() -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:names_changed(A.program())
def bad_slots() -> D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>:slots_changed(A.program())
# All three refusals consume and return the original affine App. Valid cached
# schedule/program fields are retained solely for full checkpoint observation.
def restored(~bad:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>,family:Events.State(),tick:Nat,plan:SP.Plan<F.S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<F.S>>,program:A.Program(),result:Schedule.Attachment<BaseApp.Previous(),API.Application<F.S,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4(),A.Ids,bad>>) -> A.Application & Bool:
  match result:
    case Schedule.Invalid{app}:(A.Application{API.Application{Schedule.Application{app,plan,namespace,name,steps,needs},program},family,tick},True{})
    case Schedule.Attached{API.Application{scheduled,_}}:(A.Application{API.Application{scheduled,program},family,tick},False{})
def identified(~bad:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>,family:Events.State(),tick:Nat,plan:SP.Plan<F.S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<F.S>>,program:A.Program(),app:BaseApp.Previous(),ids:A.Ids) -> A.Application & Bool:
  restored(~bad,family,tick,plan,namespace,name,steps,needs,program,API.attach(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~A.Ids,~bad,app,"Malformed",ids))
def ids_returned(~bad:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>,family:Events.State(),tick:Nat,plan:SP.Plan<F.S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<F.S>>,program:A.Program(),schema:Schema.Schema<F.S,F.Store,F.Resources>,world:F.World(),recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:B.Owners4() & (U32 & (U32 & U32))) -> A.Application & Bool:
  match result:
    case (owners,(sid,(cid,rid))):identified(~bad,family,tick,plan,namespace,name,steps,needs,program,SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},A.ids(sid,cid,rid))
def attempt(~bad:D.Program<F.S,F.Store,F.Resources,F.Events(),A.Ids>,value:A.Application) -> A.Application & Bool:
  match value:
    case A.Application{API.Application{Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},program},family,tick}:ids_returned(~bad,family,tick,plan,namespace,name,steps,needs,program,schema,world,recipe,debug,Dispatch.identified(owners))
type Report is Data:Report{refused:List<&2,Bool>,checkpoints:List<&2,C.Checkpoint>}
def finish(flags:List<&2,Bool>,views:List<&2,C.Checkpoint>,result:A.Application & C.Checkpoint) -> Report:
  match result:
    case (_,view):Report{flags,List.append(&2,C.Checkpoint,views,[view])}
def slot_result(flags:List<&2,Bool>,views:List<&2,C.Checkpoint>,result:A.Application & Bool) -> Report:
  match result:
    case (app,flag):finish(List.append(&2,Bool,flags,[flag]),views,C.checkpoint(app,True{}))
def names_view(flags:List<&2,Bool>,views:List<&2,C.Checkpoint>,result:A.Application & C.Checkpoint) -> Report:
  match result:
    case (app,view):slot_result(flags,List.append(&2,C.Checkpoint,views,[view]),attempt(~bad_slots(),app))
def names_result(flags:List<&2,Bool>,views:List<&2,C.Checkpoint>,result:A.Application & Bool) -> Report:
  match result:
    case (app,flag):names_view(List.append(&2,Bool,flags,[flag]),views,C.checkpoint(app,True{}))
def width_view(flags:List<&2,Bool>,views:List<&2,C.Checkpoint>,result:A.Application & C.Checkpoint) -> Report:
  match result:
    case (app,view):names_result(flags,List.append(&2,C.Checkpoint,views,[view]),attempt(~bad_names(),app))
def width_result(views:List<&2,C.Checkpoint>,result:A.Application & Bool) -> Report:
  match result:
    case (app,flag):width_view([flag],views,C.checkpoint(app,True{}))
def before(result:A.Application & C.Checkpoint) -> Report:
  match result:
    case (app,view):width_result([view],attempt(~bad_width(),app))
def attached(result:A.Attachment) -> Maybe<&2,Report>:
  match result:
    case A.Attached{app}:Some{before(C.checkpoint(app,True{}))}
    case A.Invalid{_}:None{}
def constructed(factory:U32,result:BaseApp.Construction) -> Maybe<&2,Report>:
  match result:
    case BaseApp.Ready{app}:attached(A.attach(BaseApp.publish(app)))
    case BaseApp.ServiceRejected{_}:None{}
    case BaseApp.ComponentRejected{_}:None{}
    case BaseApp.ResourceRejected{_}:None{}
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
    case (world,_):constructed(factory,BaseApp.construct(W.enqueue(~F.S,~F.Store,~F.Resources,~F.Events(),world,barrier)))
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
