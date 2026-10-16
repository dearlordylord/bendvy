import Base
import fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-audit61/app-a-owned-handoff-v1/owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as RA
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-capture-query.bend as Prior
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local

def element(value:Array<U32>) -> Array<U32> & String:Dump.u32_array(value)
def array(value:Array<Array<U32>>) -> Array<Array<U32>> & String:Dump.array(~Array<U32>,~element,value)
def items_join(~P:Type,head:P & String,tail:List<P> & String) -> List<P> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,"cons(" ++ ht ++ "," ++ tt ++ ")")
def items(~P:Type,~view:P -> P & String,values:List<P>) -> List<P> & String:
  match values:
    case []:([],"[]")
    case head <> tail:items_join(~P,view(head),items(~P,~view,tail))
def strings(values:List<&2,String>) -> String:List.show(&2,String,x=>x,values)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def identity(ns:U32,id:U32,name:String,access:List<&2,String>,cursor:U32) -> String:
  "namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ U32.show(cursor)
def resources_join(target:Array<Array<U32>> & String,same:Array<Array<U32>> & String,other:Array<U32> & String) -> F.Resources() & String:
  (target,tt)=target
  (same,st)=same
  (other,ot)=other
  (Product.Owner{target,Product.Owner{same,other}},"target=" ++ tt ++ ";sameSibling=" ++ st ++ ";otherSibling=" ++ ot)
def resources(value:F.Resources()) -> F.Resources() & String:
  match value:
    case Product.Owner{target,Product.Owner{same,other}}:resources_join(array(target),array(same),element(other))
def unit(value:Unit) -> String:"Unit"
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,liveObserved:Array<Bool> & String,storeObserved:F.Store(~S) & String,resourceObserved:F.Resources() & String,pendingObserved:List<(F.World(~S) -> F.World(~S))> & Nat) -> F.World(~S) & String:
  (live,lt)=liveObserved
  (store,st)=storeObserved
  (resource,rt)=resourceObserved
  (pending,count)=pendingObserved
  (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},"world{namespace=" ++ U32.show(ns) ++ ";nextId=" ++ U32.show(next) ++ ";highWater=" ++ U32.show(high) ++ ";live=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store={" ++ st ++ "};resources={" ++ rt ++ "};events=" ++ List.show(&2,Unit,unit,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,regs) ++ ";nextSystemId=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,value:F.World(~S)) -> F.World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,Dump.bool_array(live),Dump.column(~S,~Array<Array<U32>>,~array,store),resources(resource),Dump.callbacks(~F.World(~S),~F.World(~S),pending))
def owned_join(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,observed:Array<Array<U32>> & String) -> F.Owned(~S) & String:
  (capture,text)=observed
  (System.Owner{Sys.Registry{ns,id,name,access,cursor},capture},"owner{" ++ identity(ns,id,name,access,cursor) ++ ";capture=" ++ text ++ "}")
def owned(~S:Data,value:F.Owned(~S)) -> F.Owned(~S) & String:
  match value:
    case System.Owner{Sys.Registry{ns,id,name,access,cursor},capture}:owned_join(~S,ns,id,name,access,cursor,array(capture))
def prior_join(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,observed:Array<U32> & String) -> F.PriorOwned(~S) & String:
  (capture,text)=observed
  (Prior.Owner{Local.Instance{ns,id,name,access,capture},cursor},"prior{" ++ identity(ns,id,name,access,cursor) ++ ";capture=" ++ text ++ "}")
def prior(~S:Data,value:F.PriorOwned(~S)) -> F.PriorOwned(~S) & String:
  match value:
    case Prior.Owner{Local.Instance{ns,id,name,access,capture},cursor}:prior_join(~S,ns,id,name,access,cursor,element(capture))
def previous_join(~S:Data,observed:F.PriorOwned(~S) & String) -> F.Previous(~S) & String:
  (owner,text)=observed
  ((Unit{},owner),"previous{initial=Unit;" ++ text ++ "}")
def previous(~S:Data,value:F.Previous(~S)) -> F.Previous(~S) & String:
  match value:
    case (Unit{},owner):previous_join(~S,prior(~S,owner))
def app_join(~S:Data,+debug:Bool,observedWorld:F.World(~S) & String,observedPrevious:F.Previous(~S) & String,observedOwner:F.Owned(~S) & String) -> F.Application(~S) & String:
  (world,wt)=observedWorld
  (before,bt)=observedPrevious
  (owner,ot)=observedOwner
  (Build.Registered{world,(before,owner),Tree.Recipe{},debug},"app{debug=" ++ Bool.show(debug) ++ ";previousOwners=" ++ bt ++ ";recipe=Recipe|" ++ wt ++ "|" ++ ot ++ "}")
def app(~S:Data,value:F.Application(~S)) -> F.Application(~S) & String:
  match value:
    case Build.Registered{current,(before,owner),Tree.Recipe{},debug}:app_join(~S,debug,world(~S,current),previous(~S,before),owned(~S,owner))
def args_join(~S:Data,+target:W.Handle<S>,+fail:Bool,a:Array<Array<U32>> & String,b:Array<Array<U32>> & String,c:Array<U32> & String,d:Array<Array<U32>> & String,e:Array<U32> & String) -> F.Args<S> & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (d,dt)=d
  (e,et)=e
  (F.Args{target,a,b,c,d,e,fail},"args{target=" ++ handle(~S,target) ++ ";component=" ++ at ++ ";resource=" ++ bt ++ ";resourceElement=" ++ ct ++ ";capture=" ++ dt ++ ";captureElement=" ++ et ++ ";fail=" ++ Bool.show(fail) ++ "}")
def args(~S:Data,value:F.Args<S>) -> F.Args<S> & String:
  match value:
    case F.Args{target,a,b,c,d,e,fail}:args_join(~S,target,fail,array(a),array(b),element(c),array(d),element(e))
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def error_data(+value:W.WorldError) -> W.WorldError & String:(value,world_error(value))
def error_owner(value:W.WorldError) -> W.WorldError & String:error_data(value)
def output_join(a:List<Maybe<Array<Array<U32>>>> & String,b:List<Array<Array<U32>>> & String,c:List<Array<U32>> & String,d:List<W.WorldError> & String) -> F.Output & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (d,dt)=d
  (F.Output{a,b,c,d},"output{components=" ++ at ++ ";arrays=" ++ bt ++ ";elements=" ++ ct ++ ";errors=" ++ dt ++ "}")
def output(value:F.Output) -> F.Output & String:
  match value:
    case F.Output{a,b,c,d}:output_join(items(~Maybe<Array<Array<U32>>>,~Dump.optional(~Array<Array<U32>>,~array),a),items(~Array<Array<U32>>,~array,b),items(~Array<U32>,~element,c),items(~W.WorldError,~error_owner,d))
def component_join(~S:Data,+target:W.Handle<S>,+stamp:Life.Stamp,observed:Maybe<Array<Array<U32>>> & String) -> RC.Record<S,Array<Array<U32>>> & String:
  (payload,text)=observed
  (RC.Record{target,stamp,payload},"component{handle=" ++ handle(~S,target) ++ ";stamp=" ++ Dump.stamp(stamp) ++ ";payload=" ++ text ++ "}")
def component(~S:Data,value:RC.Record<S,Array<Array<U32>>>) -> RC.Record<S,Array<Array<U32>>> & String:
  match value:
    case RC.Record{target,stamp,payload}:component_join(~S,target,stamp,Dump.optional(~Array<Array<U32>>,~array,payload))
def replaced(observed:Array<Array<U32>> & String) -> RA.Record<Array<U32>> & String:
  (value,text)=observed
  (RA.Replaced{value},"Replaced{" ++ text ++ "}")
def swapped(+index:U32,observed:Array<U32> & String) -> RA.Record<Array<U32>> & String:
  (value,text)=observed
  (RA.Swapped{index,value},"Swapped{index=" ++ U32.show(index) ++ ";value=" ++ text ++ "}")
def array_record(value:RA.Record<Array<U32>>) -> RA.Record<Array<U32>> & String:
  match value:
    case RA.Replaced{value}:replaced(array(value))
    case RA.Swapped{index,value}:swapped(index,element(value))
def recovery_join(~S:Data,a:List<RC.Record<S,Array<Array<U32>>>> & String,b:List<RA.Record<Array<U32>>> & String,c:List<RA.Record<Array<U32>>> & String) -> F.Recovery(~S) & String:
  (a,at)=a
  (b,bt)=b
  (c,ct)=c
  (Product.Owner{a,Product.Owner{b,c}},"recovery{components=" ++ at ++ ";resource=" ++ bt ++ ";capture=" ++ ct ++ "}")
def recovery(~S:Data,value:F.Recovery(~S)) -> F.Recovery(~S) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,c}}:recovery_join(~S,items(~RC.Record<S,Array<Array<U32>>>,~component(~S),a),items(~RA.Record<Array<U32>>,~array_record,b),items(~RA.Record<Array<U32>>,~array_record,c))
def mode(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"Read"
    case Query.Write{}:"Write"
    case Query.Optional{}:"Optional"
    case Query.With{}:"With"
    case Query.Without{}:"Without"
    case Query.Added{}:"Added"
    case Query.Changed{}:"Changed"
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{key,m}:key ++ ":" ++ mode(m)
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,clauses}:"binding{" ++ identity(ns,id,name,access,cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses) ++ "}"
def debug_view(~S:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Unit>>>) -> String:
  match value:
    case None{}:"None"
    case Some{DTO.Product{bindings,DTO.Observation{Unit{},rendered}}}:"Some{bindings=" ++ List.show(&2,DTO.Binding<S>,binding(~S),bindings) ++ ";observation={rows=Unit;rendered=" ++ strings(rendered) ++ "}}"
def category(value:Access.Category) -> String:
  match value:
    case Access.Components{}:"Components"
    case Access.Resources{}:"Resources"
    case Access.Events{}:"Events"
    case Access.Services{}:"Services"
def role(value:Access.Role) -> String:
  match value:
    case Access.Reader{}:"Reader"
    case Access.Writer{}:"Writer"
    case Access.Filter{}:"Filter"
def use(value:Access.Use) -> String:
  match value:
    case Access.Use{ns,id,name,m,r}:"use{namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";mode=" ++ mode(m) ++ ";role=" ++ role(r) ++ "}"
def entry(value:Access.Entry) -> String:
  match value:
    case Access.Entry{cat,key,uses}:"entry{category=" ++ category(cat) ++ ";key=" ++ key ++ ";uses=" ++ List.show(&2,Access.Use,use,uses) ++ "}"
def access_view(value:Maybe<&2,List<&2,Access.Entry>>) -> String:
  match value:
    case None{}:"None"
    case Some{entries}:"Some{" ++ List.show(&2,Access.Entry,entry,entries) ++ "}"
