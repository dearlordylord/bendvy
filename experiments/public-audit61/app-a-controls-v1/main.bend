import Base
import bundle.bend as B
import resources.bend as R
import component.bend as Component
import systems.bend as Systems
import install.bend as Install
import observe.bend as Observe
import inspect.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
type Snapshot is Data:
  Snapshot{stage:String,world:String,owners:Maybe<&2,Observe.OwnerViews>,selected:Maybe<&2,Inspect.Views>}
type Report is Data:
  Report{snapshots:List<&2,Snapshot>,schedule:List<&2,Sch.Observation>,status:String}
def condition(world:B.World(R.Resources()),id:U32) -> B.World(R.Resources()) & Bool:
  (world,True{})
def repeated_world(snapshots:List<&2,Snapshot>,observations:List<&2,Sch.Observation>,status:String,owners:Observe.OwnerViews,views:Inspect.Views,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,after):Report{List.append(&2,Snapshot,snapshots,[Snapshot{"after-repeated-inspect",after,Some{owners},Some{views}}]),observations,status}
def repeated_inspect(snapshots:List<&2,Snapshot>,observations:List<&2,Sch.Observation>,status:String,owners:Observe.OwnerViews,result:B.World(R.Resources()) & Inspect.Views) -> Report:
  match result:
    case (world,views):repeated_world(snapshots,observations,status,owners,views,Observe.world(world))
def final_after_inspection(handle:W.Handle<B.AuditWorkshop>,+snapshots:List<&2,Snapshot>,+observations:List<&2,Sch.Observation>,+status:String,+before:String,+owners:Observe.OwnerViews,+views:Inspect.Views,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,after):repeated_inspect(List.append(&2,Snapshot,snapshots,[Snapshot{"after-schedule-before-inspect",before,Some{owners},None{}},Snapshot{"after-inspect",after,Some{owners},Some{views}}]),observations,status,owners,Inspect.snapshot(world,handle))
def inspected(handle:W.Handle<B.AuditWorkshop>,+snapshots:List<&2,Snapshot>,+observations:List<&2,Sch.Observation>,+status:String,+before:String,+owners:Observe.OwnerViews,result:B.World(R.Resources()) & Inspect.Views) -> Report:
  match result:
    case (world,+views):final_after_inspection(handle,snapshots,observations,status,before,owners,views,Observe.world(world))
def after_world(+handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,observations:List<&2,Sch.Observation>,status:String,owners:Observe.OwnerViews,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,before):inspected(handle,snapshots,observations,status,before,owners,Inspect.snapshot(world,handle))
def after_owners(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,observations:List<&2,Sch.Observation>,status:String,world:B.World(R.Resources()),result:Systems.Owners & Observe.OwnerViews) -> Report:
  match result:
    case (owners,view):after_world(handle,snapshots,observations,status,view,Observe.world(world))
def executed(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,result:Sch.RunResult<B.AuditWorkshop,B.Store,R.Resources(),U32,Systems.Owners,Systems.Error>) -> Report:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,name,steps,owners},world,observations}:after_owners(handle,snapshots,observations,"Finished:" ++ name,world,Observe.owners(owners))
    case Sch.Failed{Sch.Schedule{namespace,name,steps,owners},world,error,observations}:after_owners(handle,snapshots,observations,"Failed:" ++ name,world,Observe.owners(owners))
    case Sch.Rejected{Sch.Schedule{namespace,name,steps,owners},world}:after_owners(handle,snapshots,[],"Rejected:" ++ name,world,Observe.owners(owners))
def built(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,world:B.World(R.Resources()),result:Sch.Build<B.AuditWorkshop,B.Store,R.Resources(),U32,Systems.Owners>) -> Report:
  match result:
    case Sch.Built{schedule}:executed(handle,snapshots,Sch.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Systems.Owners,~Systems.Error,~Systems.dispatch,~condition,schedule,world))
    case Sch.Invalid{owners}:after_owners(handle,snapshots,[],"Invalid",world,Observe.owners(owners))
def before_schedule_namespace(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,owners:Systems.Owners,result:B.World(R.Resources()) & U32) -> Report:
  match result:
    case (world,namespace):built(handle,snapshots,world,Sch.build(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Systems.Owners,namespace,"AuditPipeline",[Sch.Phase{"Installed"},Sch.System{1,0},Sch.Barrier{},Sch.System{2,0},Sch.Barrier{}],[1,2],owners))
def before_schedule_world(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,owners:Systems.Owners,view:Observe.OwnerViews,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,text):before_schedule_namespace(handle,List.append(&2,Snapshot,snapshots,[Snapshot{"registered",text,Some{view},None{}}]),owners,W.namespace(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,world))
def before_schedule_owners(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,world:B.World(R.Resources()),result:Systems.Owners & Observe.OwnerViews) -> Report:
  match result:
    case (owners,view):before_schedule_world(handle,snapshots,owners,view,Observe.world(world))
def resource_defined(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,component:Systems.ComponentOwner(),result:Field.Defined<B.AuditWorkshop,B.World(R.Resources()),Systems.ResourceRegistry(),Field.clauses(~B.AuditWorkshop,~Systems.Tx(),~R.Ops(Systems.Tx()),R.declaration())>) -> Report:
  match result:
    case Field.Defined{world,resource}:before_schedule_owners(handle,snapshots,world,Observe.owners(Systems.Owners{component,resource}))
    case Field.Rejected{world}:Report{snapshots,[],"resource-registration-rejected"}
def component_defined(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,result:Ordinary.Defined<B.AuditWorkshop,B.World(R.Resources()),Systems.ComponentRegistry()>) -> Report:
  match result:
    case Ordinary.Defined{world,component}:resource_defined(handle,snapshots,component,Field.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body,world,"CounterTransaction"))
    case Ordinary.Rejected{world}:Report{snapshots,[],"component-registration-rejected"}
def flushed(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,text):component_defined(handle,List.append(&2,Snapshot,snapshots,[Snapshot{"explicit-flush",text,None{},None{}}]),Ordinary.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Component.Ops,~Unit,~Unit,~Unit,~Component.declaration(),~Component.body,world,"ScalarTransaction","AuditPipeline"))
def prepared(handle:W.Handle<B.AuditWorkshop>,snapshots:List<&2,Snapshot>,result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,text):flushed(handle,List.append(&2,Snapshot,snapshots,[Snapshot{"bundle-committed-before-flush",text,None{},None{}}]),Observe.world(W.barrier(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,world)))
def seeded(snapshots:List<&2,Snapshot>,result:Install.Seeded) -> Report:
  match result:
    case Install.Seeded{world,handle}:prepared(handle,snapshots,Observe.world(world))
    case Install.SeedRejected{world,payloads,raw}:Report{snapshots,[],"bundle-rejected"}
def initial(result:B.World(R.Resources()) & String) -> Report:
  match result:
    case (world,text):seeded([Snapshot{"created",text,None{},None{}}],Install.seed(world))
def created(result:W.Creation<B.AuditWorkshop,B.Store,R.Resources(),U32>) -> Report:
  match result:
    case W.Created{factory,world}:initial(Observe.world(world))
    case W.CreateRejected{factory,resource}:Report{[],[],"creation-rejected"}
def main() -> Report:
  created(W.create(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~B.empty,W.factory(),R.initial()))
