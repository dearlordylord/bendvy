import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
import ../metadata.bend as M
import ../index.bend as Index
import ./owner-observation.bend as Owner
import ./registered-identity.bend as Identity
import ./registered-consumer.bend as Original
import ./definition-v2.bend as Definition
# One declaration instance is retained with its actual registration and owned
# Provisioned schedule. Names do not resolve tokens or grant capabilities.
type Registry is Type:
  Registry{owner:Sys.Registry<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Original.Error,Unit,Original.body>,definition:Definition.Definition<Owner.Schema>}
type Prepared is Type:
  Prepared{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>}
  RegistrationFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>}
  ScheduleFailed{world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,owner:Registry}
def built(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,result:Provision.Build<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>) -> Prepared:
  match result:
    case Provision.Built{schedule}:Prepared{world,schedule}
    case Provision.Invalid{owner}:ScheduleFailed{world,owner}
def plan(+id:U32,definition:Definition.Definition<Owner.Schema>) -> Provision.Plan<Owner.Schema>:
  Provision.Sequence{Provision.Entry{Schedule.Barrier{},[]},Provision.Sequence{Provision.Entry{Schedule.System{id,0},Definition.provision_needs(~Owner.Schema,definition)},Provision.Entry{Schedule.Phase{"applyStateTransitions"},[]}}}
def identity_join(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,+definition:Definition.Definition<Owner.Schema>,result:Sys.Registry<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Original.Error,Unit,Original.body> & Identity.Identity) -> Prepared:
  match result:
    case (owner,Identity.Identity{namespace,+id}):built(world,Provision.build(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Registry,namespace,"main",plan(id,definition),[id],Registry{owner,definition}))
def registered(definition:Definition.Definition<Owner.Schema>,result:Sys.RegistrationResult<Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Original.Error,Unit,Original.body>) -> Prepared:
  match result:
    case Sys.RegistrationFailed{world}:RegistrationFailed{world}
    case Sys.Registered{world,owner}:identity_join(world,definition,Identity.observe(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Original.Error,~Unit,~Original.body,owner))
def prepare(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>,+definition:Definition.Definition<Owner.Schema>) -> Prepared:
  registered(definition,Sys.register(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Original.Error,~Unit,~Original.body,world,Definition.name(~Owner.Schema,definition),Definition.registration_access(~Owner.Schema,definition)))
type View is Data:
  View{schedule:M.Schedule,system:M.System,requirements:List<&2,Provision.Requirement<Owner.Schema>>,valid:Bool,namespace:U32,id:U32,cursor:U32}
def joined(schedule:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>,+definition:Definition.Definition<Owner.Schema>,name:String,+needs:List<&2,Provision.Requirement<Owner.Schema>>,namespace:U32,id:U32,cursor:U32,namespaceOK:Bool,result:Original.StepView) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry> & View:
  match result:
    case Original.StepView{steps,positions,valid}:(schedule,View{M.Schedule{name,steps},Definition.metadata(~Owner.Schema,definition,positions),needs,Bool.and(namespaceOK,Bool.and(valid,Definition.same_needs(~Owner.Schema,needs,Definition.provision_needs(~Owner.Schema,definition)))),namespace,id,cursor})
def view(value:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registry> & View:
  match value:
    case Provision.Provisioned{Schedule.Schedule{+namespace,+name,+input,Registry{Sys.Registry{+ownerNamespace,+id,+systemName,+access,+cursor},+definition}},+needs}:joined(Provision.Provisioned{Schedule.Schedule{namespace,name,input,Registry{Sys.Registry{ownerNamespace,id,systemName,access,cursor},definition}},needs},definition,name,needs,namespace,id,cursor,Bool.and(U32.is_eq(namespace,ownerNamespace),Bool.and(String.eq(systemName,Definition.name(~Owner.Schema,definition)),W.access_equal(access,Definition.registration_access(~Owner.Schema,definition)))),Original.steps(input,id,name,Zero{}))
