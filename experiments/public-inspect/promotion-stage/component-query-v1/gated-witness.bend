import Base
import selection.bend as Selection
import query.bend as Q
import traversal.bend as Traversal
import family-witness.bend as D
import schema-families.bend as Families
import consumer-witness.bend as Consumer
import core-v1/src/ecs/check.bend as Check
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/system.bend as Sys
import core-v1/src/ecs/schedule.bend as Sch

def no_resources(~S:Data,world:W.World<S,Families.Store<S>,Unit,U32>) -> W.World<S,Families.Store<S>,Unit,U32> & List<&2,String>:
  (world,[])
def any_rows(~H:Type,~S:Data,~V:Data,observed:H & List<&2,Q.Row<S,V>>) -> H & Bool:
  match observed:
    case (owner,[]):(owner,False{})
    case (owner,_ <> _):(owner,True{})
def body(~H:Type,~S:Data,~V:Data,~caps:Consumer.Reads<H,S,V>,args:Unit,owner:H) -> H & Bool:
  any_rows(~H,~S,~V,Q.each(~H,~S,~V,~Consumer.query_field(~H,~S,~V,caps),owner))
def checked(~S:Data,value:Check.Checked<S,Families.Store<S>,Unit,U32>) -> W.World<S,Families.Store<S>,Unit,U32> & Bool:
  match value:
    case Check.Checked{world,Done{allowed}}:(world,allowed)
    case Check.Checked{world,Fail{_}}:(world,False{})
def workshop_ops(H:Type) -> Type:
  Consumer.Reads<H,Families.Workshop,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>
def workshop_plan() -> Check.Plan<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,workshop_ops>:
  Check.Plan{no_resources(~Families.Workshop),Consumer.Reads{Q.grant(~Check.Frame<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,~Families.Workshop,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~D.check_declaration(~Families.Workshop),~Traversal.check_world(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32))}}
def workshop_body(~H:Type,~caps:Consumer.Reads<H,Families.Workshop,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>,args:Unit,owner:H) -> H & Bool:
  body(~H,~Families.Workshop,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~caps,args,owner)
def workshop_condition(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,key:U32) -> W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32> & Bool:
  checked(~Families.Workshop,Check.run(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~workshop_ops,~Unit,~workshop_body,~workshop_plan(),Unit{},world))
def workshop_runner(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,args:Unit) -> Sys.Outcome<W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,Unit,Unit>:
  Sys.Succeeded{world,args}
type WorkshopHolder is Type:
  WorkshopHolder{registry:Sys.Registry<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,Unit,Unit,Unit,workshop_runner>}
def workshop_dispatched(value:Sys.RunResult<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,Unit,Unit,Unit,workshop_runner>) -> WorkshopHolder & Sys.Outcome<W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,Unit,Unit>:
  match value:
    case Sys.Completed{registry,outcome}:(WorkshopHolder{registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(WorkshopHolder{registry},Sys.Failed{world,Unit{}})
def workshop_dispatch(holder:WorkshopHolder,world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,id:U32) -> WorkshopHolder & Sys.Outcome<W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,Unit,Unit>:
  match holder:
    case WorkshopHolder{registry}:workshop_dispatched(Sys.run(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~Unit,~Unit,~Unit,~workshop_runner,registry,world,Unit{}))
def workshop_register(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>) -> Sys.RegistrationResult<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,Unit,Unit,Unit,workshop_runner>:
  Sys.register(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~Unit,~Unit,~Unit,~workshop_runner,world,"Workshop/ComponentQueryGate",[])
def workshop_run(schedule:Sch.Schedule<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,WorkshopHolder>,world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>) -> Sch.RunResult<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,WorkshopHolder,Unit>:
  Sch.run(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~WorkshopHolder,~Unit,~workshop_dispatch,~workshop_condition,schedule,world)
def garden_ops(H:Type) -> Type:
  Consumer.Reads<H,Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>
def garden_plan() -> Check.Plan<Families.Garden,Families.Store<Families.Garden>,Unit,U32,garden_ops>:
  Check.Plan{no_resources(~Families.Garden),Consumer.Reads{Q.grant(~Check.Frame<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,~Families.Garden,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~D.check_declaration(~Families.Garden),~Traversal.check_world(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32))}}
def garden_body(~H:Type,~caps:Consumer.Reads<H,Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>,args:Unit,owner:H) -> H & Bool:
  body(~H,~Families.Garden,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~caps,args,owner)
def garden_condition(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,key:U32) -> W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32> & Bool:
  checked(~Families.Garden,Check.run(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~garden_ops,~Unit,~garden_body,~garden_plan(),Unit{},world))
def garden_runner(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,args:Unit) -> Sys.Outcome<W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,Unit,Unit>:
  Sys.Succeeded{world,args}
type GardenHolder is Type:
  GardenHolder{registry:Sys.Registry<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Unit,Unit,garden_runner>}
def garden_dispatched(value:Sys.RunResult<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Unit,Unit,garden_runner>) -> GardenHolder & Sys.Outcome<W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,Unit,Unit>:
  match value:
    case Sys.Completed{registry,outcome}:(GardenHolder{registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(GardenHolder{registry},Sys.Failed{world,Unit{}})
def garden_dispatch(holder:GardenHolder,world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,id:U32) -> GardenHolder & Sys.Outcome<W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,Unit,Unit>:
  match holder:
    case GardenHolder{registry}:garden_dispatched(Sys.run(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~Unit,~Unit,~Unit,~garden_runner,registry,world,Unit{}))
def garden_register(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>) -> Sys.RegistrationResult<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Unit,Unit,garden_runner>:
  Sys.register(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~Unit,~Unit,~Unit,~garden_runner,world,"Garden/ComponentQueryGate",[])
def garden_run(schedule:Sch.Schedule<Families.Garden,Families.Store<Families.Garden>,Unit,U32,GardenHolder>,world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>) -> Sch.RunResult<Families.Garden,Families.Store<Families.Garden>,Unit,U32,GardenHolder,Unit>:
  Sch.run(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~GardenHolder,~Unit,~garden_dispatch,~garden_condition,schedule,world)
type WorkshopStarted is Type:
  WorkshopStartedRan{result:Sch.RunResult<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,WorkshopHolder,Unit>}
  WorkshopStartedRegistrationFailed{world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>}
  WorkshopStartedBuildFailed{world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,holder:WorkshopHolder}
def workshop_built(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,built:Sch.Build<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,WorkshopHolder>) -> WorkshopStarted:
  match built:
    case Sch.Built{schedule}:WorkshopStartedRan{workshop_run(schedule,world)}
    case Sch.Invalid{holder}:WorkshopStartedBuildFailed{world,holder}
def workshop_named(holder:WorkshopHolder,+id:U32,named:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32> & U32) -> WorkshopStarted:
  (world,namespace)=named
  workshop_built(world,Sch.build(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~WorkshopHolder,namespace,"Workshop/ComponentGate",[Sch.System{id,0}],[id],holder))
def workshop_identified(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>,identified:Sys.Registry<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,Unit,Unit,Unit,workshop_runner> & U32) -> WorkshopStarted:
  (registry,id)=identified
  workshop_named(WorkshopHolder{registry},id,W.namespace(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,world))
def workshop_registered(value:Sys.RegistrationResult<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32,Unit,Unit,Unit,workshop_runner>) -> WorkshopStarted:
  match value:
    case Sys.Registered{world,registry}:workshop_identified(world,Sys.identity(~Families.Workshop,~Families.Store<Families.Workshop>,~Unit,~U32,~Unit,~Unit,~Unit,~workshop_runner,registry))
    case Sys.RegistrationFailed{world}:WorkshopStartedRegistrationFailed{world}
def workshop_start(world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Unit,U32>) -> WorkshopStarted:
  workshop_registered(workshop_register(world))
type GardenStarted is Type:
  GardenStartedRan{result:Sch.RunResult<Families.Garden,Families.Store<Families.Garden>,Unit,U32,GardenHolder,Unit>}
  GardenStartedRegistrationFailed{world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>}
  GardenStartedBuildFailed{world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,holder:GardenHolder}
def garden_built(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,built:Sch.Build<Families.Garden,Families.Store<Families.Garden>,Unit,U32,GardenHolder>) -> GardenStarted:
  match built:
    case Sch.Built{schedule}:GardenStartedRan{garden_run(schedule,world)}
    case Sch.Invalid{holder}:GardenStartedBuildFailed{world,holder}
def garden_named(holder:GardenHolder,+id:U32,named:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32> & U32) -> GardenStarted:
  (world,namespace)=named
  garden_built(world,Sch.build(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~GardenHolder,namespace,"Garden/ComponentGate",[Sch.System{id,0}],[id],holder))
def garden_identified(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,identified:Sys.Registry<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Unit,Unit,garden_runner> & U32) -> GardenStarted:
  (registry,id)=identified
  garden_named(GardenHolder{registry},id,W.namespace(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,world))
def garden_registered(value:Sys.RegistrationResult<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Unit,Unit,garden_runner>) -> GardenStarted:
  match value:
    case Sys.Registered{world,registry}:garden_identified(world,Sys.identity(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~Unit,~Unit,~Unit,~garden_runner,registry))
    case Sys.RegistrationFailed{world}:GardenStartedRegistrationFailed{world}
def garden_start(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>) -> GardenStarted:
  garden_registered(garden_register(world))
def main() -> Unit:
  Unit{}
