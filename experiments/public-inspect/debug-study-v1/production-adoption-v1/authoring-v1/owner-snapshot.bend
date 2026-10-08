import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
import ./registered.bend as Registered
import ./multi-registered.bend as Application
import ./render.bend as Render
import ./render-fixture.bend as R
import ../../description-v1/full-dto-v1/owner-observation.bend as Owner
# Complete detached owner controls; registered identities stay actual numeric
# observations, never reconstructed from system labels or catalog constants.
# This concrete Application access encoder emits complete JSON metadata objects;
# the access array embeds their exact text, not a generic String serializer.
def need(value:Provision.Requirement<Owner.Schema>) -> String:
  match value:
    case Provision.Component{id}:"component:"++U32.show(id)
    case Provision.Resource{id}:"resource:"++U32.show(id)
    case Provision.Service{id}:"service:"++U32.show(id)
def needs(values:List<&2,Provision.Requirement<Owner.Schema>>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:R.quote(need(head))<>needs(tail)
def step(value:Schedule.Step) -> String:
  match value:
    case Schedule.System{id,condition}:"{\"system\":"++U32.show(id)++",\"condition\":"++U32.show(condition)++"}"
    case Schedule.Barrier{}:"{\"barrier\":true}"
    case Schedule.Phase{name}:"{\"phase\":"++R.quote(name)++"}"
def steps(values:List<&2,Schedule.Step>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:step(head)<>steps(tail)
def bound(value:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>) -> Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & String:
  match value:
    case Registered.Bound{Sys.Registry{+namespace,+id,+name,+access,+cursor},+declaration}:(Registered.Bound{Sys.Registry{namespace,id,name,access,cursor},declaration},"{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++",\"name\":"++R.quote(name)++",\"access\":"++R.array(access)++",\"cursor\":"++U32.show(cursor)++",\"declaration\":"++Render.system(Application.metadata(declaration,[]))++"}")
def main_second(+ns:U32,+name:String,+input:List<&2,Schedule.Step>,+requirements:List<&2,Provision.Requirement<Owner.Schema>>,a:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>,atext:String,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & String) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & String:
  match result:
    case (c,ctext):(Provision.Provisioned{Schedule.Schedule{ns,name,input,Application.MainOwners{a,c}},requirements},"{\"namespace\":"++U32.show(ns)++",\"name\":"++R.quote(name)++",\"steps\":"++R.array(steps(input))++",\"requirements\":"++R.array(needs(requirements))++",\"owners\":["++atext++","++ctext++"]}")
def main_first(ns:U32,name:String,input:List<&2,Schedule.Step>,requirements:List<&2,Provision.Requirement<Owner.Schema>>,c:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & String) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & String:
  match result:
    case (a,atext):main_second(ns,name,input,requirements,a,atext,bound(c))
def main(value:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & String:
  match value:
    case Provision.Provisioned{Schedule.Schedule{ns,name,input,Application.MainOwners{a,c}},requirements}:main_first(ns,name,input,requirements,c,bound(a))
def again_join(+ns:U32,+name:String,+input:List<&2,Schedule.Step>,+requirements:List<&2,Provision.Requirement<Owner.Schema>>,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & String) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & String:
  match result:
    case (b,btext):(Provision.Provisioned{Schedule.Schedule{ns,name,input,b},requirements},"{\"namespace\":"++U32.show(ns)++",\"name\":"++R.quote(name)++",\"steps\":"++R.array(steps(input))++",\"requirements\":"++R.array(needs(requirements))++",\"owner\":"++btext++"}")
def again(value:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & String:
  match value:
    case Provision.Provisioned{Schedule.Schedule{ns,name,input,b},requirements}:again_join(ns,name,input,requirements,bound(b))
