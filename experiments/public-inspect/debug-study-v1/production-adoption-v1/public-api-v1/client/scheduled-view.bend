import Base
import ../candidate/src/ecs/system.bend as Sys
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/schedule.bend as Schedule
import ../candidate/src/ecs/schedule-provision.bend as Provision
import ../candidate/src/ecs/debug-metadata.bend as M
import ../candidate/src/ecs/debug-registered.bend as Registered
import ./multi-registered.bend as Application
import ./owner-observation.bend as Owner
# Detached descriptive lookup uses actual registry ids; names remain labels.
type Label is Data:
  Label{id:U32,name:String}
def choose(found:Bool,name:String,other:Maybe<&2,String>) -> Maybe<&2,String>:
  match found:
    case True{}:Some{name}
    case False{}:other
def lookup(rows:List<&2,Label>,+id:U32) -> Maybe<&2,String>:
  match rows:
    case []:None{}
    case Label{candidate,name}<>tail:choose(U32.is_eq(candidate,id),name,lookup(tail,id))
type Steps is Data:
  Steps{steps:List<&2,M.Step>,valid:Bool}
def run_step(found:Maybe<&2,String>,condition:U32,next:Steps) -> Steps:
  match found next:
    case Some{name} Steps{steps,ok}:Steps{M.Run{name}<>steps,Bool.and(U32.is_eq(condition,0),ok)}
    case None{} Steps{steps,_}:Steps{steps,False{}}
def barrier(next:Steps) -> Steps:
  match next:
    case Steps{steps,ok}:Steps{M.ApplyDeferred{}<>steps,ok}
def phase(name:String,next:Steps) -> Steps:
  match next:
    case Steps{steps,ok}:Steps{M.ApplyStateTransitions{[]}<>steps,Bool.and(String.eq(name,"applyStateTransitions"),ok)}
def steps(input:List<&2,Schedule.Step>,+labels:List<&2,Label>) -> Steps:
  match input:
    case []:Steps{[],True{}}
    case Schedule.System{id,condition}<>tail:run_step(lookup(labels,id),condition,steps(tail,labels))
    case Schedule.Barrier{}<>tail:barrier(steps(tail,labels))
    case Schedule.Phase{name}<>tail:phase(name,steps(tail,labels))
def add_position(found:Bool,name:String,index:Nat,tail:List<&2,String>) -> List<&2,String>:
  match found:
    case True{}:(name++"#"++Nat.show(index))<>tail
    case False{}:tail
def positions(input:List<&2,Schedule.Step>,+id:U32,+name:String,+index:Nat) -> List<&2,String>:
  match input:
    case []:[]
    case Schedule.System{candidate,_}<>tail:add_position(U32.is_eq(candidate,id),name,index,positions(tail,id,name,Succ{index}))
    case _<>tail:positions(tail,id,name,Succ{index})
def observe(value:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>,input:List<&2,Schedule.Step>,name:String) -> Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & Registered.Observation<Owner.Schema>:
  match value:
    case Registered.Bound{Sys.Registry{namespace,+id,actualName,access,cursor},declaration}:Registered.observe(~Application.ComponentToken,~Application.ResourceToken,~Application.EventToken,~Application.MachineToken,~Application.RelationToken,~Application.ServiceToken,~Application.ConditionToken,~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Unit,~Application.Error,~Unit,~Application.body,~Application.name,~Application.access,~Application.metadata,Registered.Bound{Sys.Registry{namespace,id,actualName,access,cursor},declaration},positions(input,id,name,Zero{}))
type ResolvedRow is Data:
  ResolvedRow{id:U32,system:M.System}
def resolved_choose(found:Bool,system:M.System,other:Maybe<&2,M.System>) -> Maybe<&2,M.System>:
  match found:
    case True{}:Some{system}
    case False{}:other
def resolved_lookup(rows:List<&2,ResolvedRow>,+id:U32) -> Maybe<&2,M.System>:
  match rows:
    case []:None{}
    case ResolvedRow{candidate,system}<>tail:resolved_choose(U32.is_eq(candidate,id),system,resolved_lookup(tail,id))
def resolved_run(found:Maybe<&2,M.System>,tail:List<&2,M.ResolvedStep>) -> List<&2,M.ResolvedStep>:
  match found:
    case Some{system}:M.ResolvedSystem{system}<>tail
    case None{}:tail
# Missing ids remain invalid in the separate complete Steps validation. No name
# lookup is used to construct resolved lint subjects, even for duplicate labels.
def resolved(input:List<&2,Schedule.Step>,+rows:List<&2,ResolvedRow>) -> List<&2,M.ResolvedStep>:
  match input:
    case []:[]
    case Schedule.System{id,_}<>tail:resolved_run(resolved_lookup(rows,id),resolved(tail,rows))
    case Schedule.Barrier{}<>tail:M.ResolvedDeferred{}<>resolved(tail,rows)
    case Schedule.Phase{_}<>tail:M.ResolvedTransitions{[]}<>resolved(tail,rows)
type View is Data:
  View{schedule:M.Schedule,resolved:M.ResolvedSchedule,systems:List<&2,M.System>,requirements:List<&2,Provision.Requirement<Owner.Schema>>,namespace:U32,cursors:List<&2,U32>,valid:Bool}
def finished(owner:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>,+name:String,+needs:List<&2,Provision.Requirement<Owner.Schema>>,namespace:U32,resolution:List<&2,M.ResolvedStep>,systems:List<&2,M.System>,cursors:List<&2,U32>,valid:Bool,result:Steps) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & View:
  match result:
    case Steps{steps,ok}:(owner,View{M.Schedule{name,steps},M.ResolvedSchedule{name,resolution},systems,needs,namespace,cursors,Bool.and(valid,ok)})
def main_observed(+namespace:U32,+name:String,+input:List<&2,Schedule.Step>,+needs:List<&2,Provision.Requirement<Owner.Schema>>,a:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>,+ao:Registered.Observation<Owner.Schema>,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & Registered.Observation<Owner.Schema>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & View:
  match ao result:
    case Registered.Observation{+ans,+aid,ac,+aname,_,+asystem,+av}, (c,Registered.Observation{+cns,+cid,cc,+cname,_,+csystem,+cv}):finished(Provision.Provisioned{Schedule.Schedule{namespace,name,input,Application.MainOwners{a,c}},needs},name,needs,namespace,resolved(input,[ResolvedRow{aid,asystem},ResolvedRow{cid,csystem}]),[asystem,csystem],[ac,cc],Bool.and(av,Bool.and(cv,Bool.and(U32.is_eq(namespace,ans),U32.is_eq(namespace,cns)))),steps(input,[Label{aid,aname},Label{cid,cname}]))
def main_reader(namespace:U32,+name:String,+input:List<&2,Schedule.Step>,needs:List<&2,Provision.Requirement<Owner.Schema>>,c:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & Registered.Observation<Owner.Schema>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & View:
  match result:
    case (a,ao):main_observed(namespace,name,input,needs,a,ao,observe(c,input,name))
def main_view(value:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Application.MainOwners> & View:
  match value:
    case Provision.Provisioned{Schedule.Schedule{namespace,+name,+input,Application.MainOwners{a,c}},needs}:main_reader(namespace,name,input,needs,c,observe(a,input,name))
def again_finished(owner:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,+label:String,+needs:List<&2,Provision.Requirement<Owner.Schema>>,namespace:U32,resolution:List<&2,M.ResolvedStep>,system:M.System,cursor:U32,valid:Bool,result:Steps) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & View:
  match result:
    case Steps{steps,ok}:(owner,View{M.Schedule{label,steps},M.ResolvedSchedule{label,resolution},[system],needs,namespace,[cursor],Bool.and(valid,ok)})
def again_observed(+namespace:U32,ownerName:String,+label:String,+input:List<&2,Schedule.Step>,+needs:List<&2,Provision.Requirement<Owner.Schema>>,result:Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body> & Registered.Observation<Owner.Schema>) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & View:
  match result:
    case (b,Registered.Observation{+ons,+id,cursor,+name,_,+system,+valid}):again_finished(Provision.Provisioned{Schedule.Schedule{namespace,ownerName,input,b},needs},label,needs,namespace,resolved(input,[ResolvedRow{id,system}]),system,cursor,Bool.and(valid,U32.is_eq(namespace,ons)),steps(input,[Label{id,name}]))
# Label comes from the actual owned schedule's setup binding. It changes only
# detached naming/placements, never the retained owner's identity or name.
def again_view(value:Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>>,+label:String) -> Provision.Provisioned<Owner.Schema,Array<U32>,Owner.Owner,U32,Registered.Bound<Application.ComponentToken,Application.ResourceToken,Application.EventToken,Application.MachineToken,Application.RelationToken,Application.ServiceToken,Application.ConditionToken,Owner.Schema,Array<U32>,Owner.Owner,U32,Unit,Application.Error,Unit,Application.body>> & View:
  match value:
    case Provision.Provisioned{Schedule.Schedule{namespace,ownerName,+input,b},needs}:again_observed(namespace,ownerName,label,input,needs,observe(b,input,label))
