import Base
import systems.bend as Systems
import capture.bend as P
import owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule-query.bend as QL
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule-local.bend as RL
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule-condition.bend as Guard
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-capture-query.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import bundle.bend as B

def strings(values:List<&2,String>) -> String:
  List.show(&2,String,x => x,values)
def identity(ns:U32,id:U32,name:String,access:List<&2,String>) -> String:
  "namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access)
def pack_join(first:Array<U32> & String,second:Array<U32> & String) -> P.QueryPack & String:
  (calls,a)=first
  (values,b)=second
  (P.QueryPack{calls,values},"calls=" ++ a ++ ";values=" ++ b)
def pack(value:P.QueryPack) -> P.QueryPack & String:
  match value:
    case P.QueryPack{calls,values}:pack_join(Dump.u32_array(calls),Dump.u32_array(values))
def query_join(+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,+args:Unit,+enabled:Bool,observed:P.QueryPack & String) -> Systems.QLeaf() & String:
  (capture,text)=observed
  (QL.Leaf{O.Owner{L.Instance{ns,id,name,access,capture},cursor},args,enabled},"query{" ++ identity(ns,id,name,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";args=Unit;enabled=" ++ Bool.show(enabled) ++ ";capture={" ++ text ++ "}}")
def query(value:Systems.QLeaf()) -> Systems.QLeaf() & String:
  match value:
    case QL.Leaf{O.Owner{L.Instance{ns,id,name,access,capture},cursor},args,enabled}:query_join(ns,id,name,access,cursor,args,enabled,pack(capture))
def resource_join(+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+args:Unit,+enabled:Bool,observed:Array<U32> & String) -> Systems.RLeaf() & String:
  (capture,text)=observed
  (RL.Leaf{L.Instance{ns,id,name,access,capture},args,enabled},"resource{" ++ identity(ns,id,name,access) ++ ";args=Unit;enabled=" ++ Bool.show(enabled) ++ ";capture=" ++ text ++ "}")
def resource(value:Systems.RLeaf()) -> Systems.RLeaf() & String:
  match value:
    case RL.Leaf{L.Instance{ns,id,name,access,capture},args,enabled}:resource_join(ns,id,name,access,args,enabled,Dump.u32_array(capture))
def field(value:Systems.FieldOwner()) -> Systems.FieldOwner() & String:
  match value:
    case Field.Owner{Sys.Registry{+ns,+id,+name,+access,+cursor}}:(Field.Owner{Sys.Registry{ns,id,name,access,cursor}},"field{" ++ identity(ns,id,name,access) ++ ";cursor=" ++ U32.show(cursor) ++ "}")
def owners_join(q:Systems.QLeaf() & String,r:Systems.RLeaf() & String,f:Systems.FieldOwner() & String) -> Systems.Owners() & String:
  (qo,qt)=q
  (ro,rt)=r
  (fo,ft)=f
  (((qo,ro),fo),qt ++ "|" ++ rt ++ "|" ++ ft)
def owners(value:Systems.Owners()) -> Systems.Owners() & String:
  match value:
    case ((q,r),f):owners_join(query(q),resource(r),field(f))
def leaf_description(value:Cond.LeafDescription) -> String:
  match value:
    case Cond.StateChanged{ns,id,name,access}:"StateChanged{" ++ identity(ns,id,name,access) ++ "}"
    case Cond.InState{name}:"InState{" ++ name ++ "}"
    case Cond.Constant{value}:"Constant{" ++ Bool.show(value) ++ "}"
def description(value:Cond.Description) -> String:
  match value:
    case Cond.Description{name,access,leaves}:"name=" ++ name ++ ";access=" ++ strings(access) ++ ";leaves=" ++ List.show(&2,Cond.LeafDescription,leaf_description,leaves)
def binding(value:Cond.BindingDescription) -> String:
  match value:
    case Cond.BindingDescription{id,facts}:"systemId=" ++ U32.show(id) ++ ";condition={" ++ description(facts) ++ "}"
def conditions(value:Systems.Conditions()) -> Systems.Conditions() & String:
  match value:
    case Cond.Bindings{Cond.BoundOwner{+id,+allowed},+facts}:(Cond.Bindings{Cond.BoundOwner{id,allowed},facts},"conditionOwner{id=" ++ U32.show(id) ++ ";value=" ++ Bool.show(allowed) ++ "};bindings=" ++ List.show(&2,Cond.BindingDescription,binding,facts))
def step(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ "," ++ U32.show(condition) ++ "}"
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.Barrier{}:"Barrier"
def requirement(value:SP.Requirement<B.AuditWorkshop>) -> String:
  match value:
    case SP.Component{id}:"Component{" ++ U32.show(id) ++ "}"
    case SP.Resource{id}:"Resource{" ++ U32.show(id) ++ "}"
    case SP.Service{id}:"Service{" ++ U32.show(id) ++ "}"
def plan(value:SP.Plan<B.AuditWorkshop>) -> String:
  match value:
    case SP.Empty{}:"Empty"
    case SP.Entry{value,requirements}:"Entry{" ++ step(value) ++ ";requirements=" ++ List.show(&2,SP.Requirement<B.AuditWorkshop>,requirement,requirements) ++ "}"
    case SP.Sequence{left,right}:"Sequence{" ++ plan(left) ++ "," ++ plan(right) ++ "}"
def observed(+name:String,+value:SP.Plan<B.AuditWorkshop>,own:Systems.Owners() & String,cond:Systems.Conditions() & String) -> Systems.Schedule() & String:
  (owners,ot)=own
  (conditions,ct)=cond
  (Guard.Owned{name,value,owners,conditions},"schedule{name=" ++ name ++ ";plan=" ++ plan(value) ++ "}|" ++ ot ++ "|" ++ ct)
def observe(value:Systems.Schedule()) -> Systems.Schedule() & String:
  match value:
    case Guard.Owned{name,plan,own,cond}:observed(name,plan,owners(own),conditions(cond))
