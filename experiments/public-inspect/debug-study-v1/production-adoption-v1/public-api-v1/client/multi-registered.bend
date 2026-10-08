import Base
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/system.bend as Sys
import ../candidate/src/ecs/schedule-provision.bend as Provision
import ../candidate/src/ecs/schedule.bend as Schedule
import ../candidate/src/ecs/debug-metadata.bend as M
import ../candidate/src/ecs/debug-declaration.bend as Declaration
import ../candidate/src/ecs/debug-registered.bend as Registered
import ./render.bend as Render
import ./owner-observation.bend as Owner
# Closed application tokens are labels/bindings, never runtime handles.
type ComponentToken is Data:
  ComponentPlain{}
type ResourceToken is Data:
  Plain{}
type EventToken is Data:
  EventPlain{}
type MachineToken is Data:
  MachinePlain{}
type RelationToken is Data:
  RelationPlain{}
type ServiceToken is Data:
  ServicePlain{}
type ConditionToken is Data:
  ConditionPlain{}
type Error is Data:
  Error{}
def body(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,args:Unit) -> Sys.Outcome<W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,Error,Unit>:
  Sys.Succeeded{world,Unit{}}
def component_name(value:ComponentToken) -> String:
  match value:
    case ComponentPlain{}:"plain"
def resource_name(value:ResourceToken) -> String:
  match value:
    case Plain{}:"plain"
def event_name(value:EventToken) -> String:
  match value:
    case EventPlain{}:"plain"
def machine_name(value:MachineToken) -> String:
  match value:
    case MachinePlain{}:"plain"
def relation_name(value:RelationToken) -> String:
  match value:
    case RelationPlain{}:"plain"
def service_name(value:ServiceToken) -> String:
  match value:
    case ServicePlain{}:"plain"
def condition_name(value:ConditionToken) -> String:
  match value:
    case ConditionPlain{}:"plain"
def resource(value:ResourceToken) -> Provision.Requirement<Owner.Schema>:
  match value:
    case Plain{}:Provision.Resource{1}
def service(value:ServiceToken) -> Provision.Requirement<Owner.Schema>:
  match value:
    case ServicePlain{}:Provision.Service{1}
def reader() -> Declaration.Definition<Owner.Schema,ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken>:
  Declaration.Definition{"Reader",[],[Plain{}],[],[],[],[],[],[],[],[],False{},[],[],[]}
def writer() -> Declaration.Definition<Owner.Schema,ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken>:
  Declaration.Definition{"Writer",[],[],[Plain{}],[],[],[],[],[],[],[],False{},[],[],[]}
def name(value:Declaration.Definition<Owner.Schema,ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken>) -> String:
  Declaration.name(~Owner.Schema,~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,value)
def metadata(value:Declaration.Definition<Owner.Schema,ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken>,positions:List<&2,String>) -> M.System:
  Declaration.metadata(~Owner.Schema,~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~component_name,~resource_name,~event_name,~machine_name,~relation_name,~service_name,~condition_name,value,positions)
def encode(value:M.System) -> List<&2,String>:
  [Render.system(value)]
def access(value:Declaration.Definition<Owner.Schema,ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken>) -> List<&2,String>:
  encode(metadata(value,[]))
type Owners is Type:
  Owners{readerA:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,readerB:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,writer:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
type Prepared is Type:
  Prepared{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,owners:Owners}
  FirstFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>}
  SecondFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,readerA:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
  ThirdFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,readerA:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,readerB:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
def third(a:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,b:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,result:Registered.Registration<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>) -> Prepared:
  match result:
    case Registered.Registered{world,c}:Prepared{world,Owners{a,b,c}}
    case Registered.Rejected{world}:ThirdFailed{world,a,b}
def second(a:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,result:Registered.Registration<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>) -> Prepared:
  match result:
    case Registered.Registered{world,b}:third(a,b,Registered.register(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~name,~access,world,writer()))
    case Registered.Rejected{world}:SecondFailed{world,a}
def first(result:Registered.Registration<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>) -> Prepared:
  match result:
    case Registered.Registered{world,a}:second(a,Registered.register(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~name,~access,world,reader()))
    case Registered.Rejected{world}:FirstFailed{world}
def prepare(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> Prepared:
  first(Registered.register(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~name,~access,world,reader()))

# Each actual registered instance has one affine owner. Duplicate Reader labels
# do not collapse the two independently registered ids or their schedule owners.
type MainOwners is Type:
  MainOwners{reader:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,writer:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
type Schedules is Type:
  Scheduled{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,MainOwners>,again:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>>}
  MainInvalid{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:MainOwners,again:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
  AgainInvalid{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,MainOwners>,again:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>}
def again_built(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,main:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,MainOwners>,result:Provision.Build<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>>) -> Schedules:
  match result:
    case Provision.Built{again}:Scheduled{world,main,again}
    case Provision.Invalid{again}:AgainInvalid{world,main,again}
def main_built(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,again:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,+namespace:U32,catalogB:List<&2,U32>,planB:Provision.Plan<Owner.Schema>,result:Provision.Build<Owner.Schema,Array<U32>,Owner.Owner,U32,MainOwners>) -> Schedules:
  match result:
    case Provision.Built{main}:again_built(world,main,Provision.build(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,namespace,"again",planB,catalogB,again))
    case Provision.Invalid{owners}:MainInvalid{world,owners,again}
def plan_ids(plan:Provision.Plan<Owner.Schema>) -> List<&2,U32>:
  match plan:
    case Provision.Entry{Schedule.System{id,_},_}:[id]
    case _ :[]
def entry_namespace(value:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>) -> Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & U32:
  match value:
    case Registered.Bound{Sys.Registry{+namespace,id,name,access,cursor},declaration}:(Registered.Bound{Sys.Registry{namespace,id,name,access,cursor},declaration},namespace)
def plans(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,a:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,b:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,c:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,+namespace:U32,+pa:Provision.Plan<Owner.Schema>,+pb:Provision.Plan<Owner.Schema>,+pc:Provision.Plan<Owner.Schema>) -> Schedules:
  main_built(world,b,namespace,plan_ids(pb),pb,Provision.build(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~MainOwners,namespace,"main",Provision.Sequence{Provision.Entry{Schedule.Barrier{},[]},Provision.Sequence{pa,Provision.Sequence{Provision.Entry{Schedule.Barrier{},[]},Provision.Sequence{pc,Provision.Entry{Schedule.Phase{"applyStateTransitions"},[]}}}}},List.append(&2,U32,plan_ids(pa),plan_ids(pc)),MainOwners{a,c}))
def c_plan(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,a:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,b:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,namespace:U32,pa:Provision.Plan<Owner.Schema>,pb:Provision.Plan<Owner.Schema>,result:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & Provision.Plan<Owner.Schema>) -> Schedules:
  match result:
    case (c,pc):plans(world,a,b,c,namespace,pa,pb,pc)
def b_plan(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,a:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,c:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,namespace:U32,pa:Provision.Plan<Owner.Schema>,result:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & Provision.Plan<Owner.Schema>) -> Schedules:
  match result:
    case (b,pb):c_plan(world,a,b,namespace,pa,pb,Registered.schedule_entry(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~resource,~service,0,c))
def a_plan(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,b:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,c:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,namespace:U32,result:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & Provision.Plan<Owner.Schema>) -> Schedules:
  match result:
    case (a,pa):b_plan(world,a,c,namespace,pa,Registered.schedule_entry(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~resource,~service,0,b))
def namespace_join(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,b:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,c:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body>,result:Registered.Bound<ComponentToken,ResourceToken,EventToken,MachineToken,RelationToken,ServiceToken,ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Error,Unit,body> & U32) -> Schedules:
  match result:
    case (a,namespace):a_plan(world,b,c,namespace,Registered.schedule_entry(~ComponentToken,~ResourceToken,~EventToken,~MachineToken,~RelationToken,~ServiceToken,~ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Error,~Unit,~body,~resource,~service,0,a))
def schedules(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,owners:Owners) -> Schedules:
  match owners:
    case Owners{a,b,c}:namespace_join(world,b,c,entry_namespace(a))
