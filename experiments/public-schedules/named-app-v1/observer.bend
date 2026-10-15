import Base
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-access.bend as Access
import ../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../src/ecs/local.bend as Local
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/ordinary-app-recipe.bend as Tree
import ./fixture.bend as F
import ../../../src/ecs/ordinary-app-schedules.bend as N
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../src/ecs/ordinary-app-schedule-description.bend as Detail
import ../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/ordinary-resource-system.bend as P
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch

def quoted(value:String) -> String:
  "\""++value++"\""
def strings(items:List<&2,String>) -> String:
  List.show(&2,String,quoted,items)
def requirement(~S:Data,item:SP.Requirement<S>) -> String:
  match item:
    case SP.Component{id}:"component:"++U32.show(id)
    case SP.Resource{id}:"resource:"++U32.show(id)
    case SP.Service{id}:"service:"++U32.show(id)
def requirements(~S:Data,items:List<&2,SP.Requirement<S>>) -> String:
  List.show(&2,SP.Requirement<S>,requirement(~S),items)
def step(item:Sch.Step) -> String:
  match item:
    case Sch.System{id,condition}:"system("++U32.show(id)++","++U32.show(condition)++")"
    case Sch.Phase{name}:"phase("++quoted(name)++")"
    case Sch.Barrier{}:"barrier"
def plan(~S:Data,item:SP.Plan<S>) -> String:
  match item:
    case SP.Empty{}:"empty"
    case SP.Entry{item,needs}:step(item)++requirements(~S,needs)
    case SP.Sequence{left,right}:"("++plan(~S,left)++";"++plan(~S,right)++")"
def named(~S:Data,item:N.Named<S>) -> String:
  match item:
    case N.Named{label,value}:quoted(label)++":"++plan(~S,value)
def maybe_plan(~S:Data,item:Maybe<&2,SP.Plan<S>>) -> String:
  match item:
    case None{}:"none"
    case Some{value}:"some("++plan(~S,value)++")"
def mode(item:Q.Mode) -> String:
  match item:
    case Q.Read{}:"read"
    case Q.Write{}:"write"
    case Q.Optional{}:"optional"
    case Q.With{}:"with"
    case Q.Without{}:"without"
    case Q.Added{}:"added"
    case Q.Changed{}:"changed"
def clause(~S:Data,item:Q.Clause<S>) -> String:
  match item:
    case Q.Clause{name,kind}:quoted(name)++":"++mode(kind)
def binding(~S:Data,item:DTO.Binding<S>) -> String:
  match item:
    case DTO.Binding{namespace,id,name,access,cursor,slot,clauses}:"binding("++U32.show(namespace)++","++U32.show(id)++","++quoted(name)++","++strings(access)++","++U32.show(cursor)++","++quoted(slot)++","++List.show(&2,Q.Clause<S>,clause(~S),clauses)++")"
def kind(item:Fragment.RegistryKind) -> String:
  match item:
    case Fragment.Component{}:"component"
    case Fragment.Resource{}:"resource"
    case Fragment.Event{}:"event"
    case Fragment.Relation{}:"relation"
    case Fragment.Service{}:"service"
def persistence(item:Fragment.PersistenceKind) -> String:
  match item:
    case Fragment.Plain{}:"plain"
    case Fragment.Transient{}:"transient"
    case Fragment.Constructed{}:"constructed"
def schema_entry(~S:Data,item:Fragment.Entry<S>) -> String:
  match item:
    case Fragment.Entry{category,key,name}:kind(category)++":"++quoted(key)++":"++quoted(name)
    case Fragment.Classified{category,key,name,persist}:kind(category)++":"++quoted(key)++":"++quoted(name)++":"++persistence(persist)
def app_description(~S:Data,item:App.Description<S,F.Rows()>) -> String:
  match item:
    case App.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{_,value},rendered}}}:"app("++List.show(&2,Fragment.Entry<S>,schema_entry(~S),entries)++","++List.show(&2,DTO.Binding<S>,binding(~S),bindings)++","++U32.show(value)++","++strings(rendered)++")"
def planned(~S:Data,item:Single.PlannedStep<S>) -> String:
  match item:
    case Single.PlannedStep{value,needs}:step(value)++requirements(~S,needs)
def optional_name(item:Maybe<&2,String>) -> String:
  match item:
    case None{}:"none"
    case Some{name}:quoted(name)
def placement(~S:Data,item:Detail.Placement<S>) -> String:
  match item:
    case Detail.System{position,namespace,id,name,condition,needs}:"system("++Nat.show(position)++","++U32.show(namespace)++","++U32.show(id)++","++optional_name(name)++","++U32.show(condition)++","++requirements(~S,needs)++")"
    case Detail.Phase{position,name,needs}:"phase("++Nat.show(position)++","++quoted(name)++","++requirements(~S,needs)++")"
    case Detail.Barrier{position,needs}:"barrier("++Nat.show(position)++","++requirements(~S,needs)++")"
def description(~S:Data,item:Detail.Description<S,F.Rows()>) -> String:
  match item:
    case Detail.Description{Single.Description{app,namespace,name,steps},placements}:"schedule("++app_description(~S,app)++","++U32.show(namespace)++","++quoted(name)++","++List.show(&2,Single.PlannedStep<S>,planned(~S),steps)++","++List.show(&2,Detail.Placement<S>,placement(~S),placements)++")"
def debug(~S:Data,item:Maybe<&2,N.Description<S,F.Rows()>>) -> String:
  match item:
    case None{}:"none"
    case Some{N.Description{app,plans}}:"debug("++app_description(~S,app)++","++List.show(&2,Detail.Description<S,F.Rows()>,description(~S),plans)++")"
def array_pair(result:Array<U32> & Array<U32>) -> Array<U32> & String:
  match result:
    case (values,copy):(values,List.show(&1,U32,U32.show,Array.to_list(~U32,copy)))
def array(values:Array<U32>) -> Array<U32> & String:
  array_pair(Array.clone(U32,values))
def memory_result(+count:U32,result:Array<U32> & String) -> F.Memory & String:
  match result:
    case (values,text):(F.Memory{values,count},"memory("++U32.show(count)++","++text++")")
def memory(item:F.Memory) -> F.Memory & String:
  match item:
    case F.Memory{values,count}:memory_result(count,array(values))
def field_text(~S:Data,value:Fields.Fields<S>) -> String:
  match value:
    case Fields.Fields{namespace,id,name,access,cursor,slot,clauses,_}:"registry("++U32.show(namespace)++","++U32.show(id)++","++quoted(name)++","++strings(access)++","++U32.show(cursor)++","++quoted(slot)++","++List.show(&2,Q.Clause<S>,clause(~S),clauses)++")"
def owner(~S:Data,item:F.Reader(~S)) -> F.Reader(~S) & String:
  match item:
    case Leaf.Record{token,+fields}:(Leaf.Record{token,fields},field_text(~S,fields))
def registration(item:W.RegistrationMeta) -> String:
  match item:
    case W.RegistrationMeta{id,name,access}:"registration("++U32.show(id)++","++quoted(name)++","++strings(access)++")"
def paired_right(~A:Type,~B:Type,left:A,leftText:String,result:B & String) -> (A & B) & String:
  match result:
    case (right,rightText):((left,right),"("++leftText++","++rightText++")")
def paired_left(~A:Type,~B:Type,~right:B -> B & String,value:B,result:A & String) -> (A & B) & String:
  match result:
    case (left,text):paired_right(~A,~B,left,text,right(value))
def pair(~A:Type,~B:Type,~left:A -> A & String,~right:B -> B & String,value:A & B) -> (A & B) & String:
  match value:
    case (a,b):paired_left(~A,~B,~right,b,left(a))
def bool_show(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def local_observed(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,result:F.Memory & String) -> F.local_owner(~S) & String:
  match result:
    case (memory,text):(LF.Owner{Local.Instance{namespace,id,name,access,memory}},"local("++U32.show(namespace)++","++U32.show(id)++","++quoted(name)++","++strings(access)++","++text++")")
def local_owner(~S:Data,value:F.local_owner(~S)) -> F.local_owner(~S) & String:
  match value:
    case LF.Owner{Local.Instance{namespace,id,name,access,local}}:local_observed(~S,namespace,id,name,access,memory(local))
def owners_observed(~S:Data,result:(F.local_owner(~S) & (F.local_owner(~S) & F.Reader(~S))) & String) -> F.Owners(~S) & String:
  match result:
    case ((first,(second,reader)),text):((((Unit{},first),second),reader),text)
def owners(~S:Data,value:F.Owners(~S)) -> F.Owners(~S) & String:
  match value:
    case (((_,first),second),reader):owners_observed(~S,pair(~F.local_owner(~S),~(F.local_owner(~S) & F.Reader(~S)),~local_owner(~S),~pair(~F.local_owner(~S),~F.Reader(~S),~local_owner(~S),~owner(~S)),(first,(second,reader))))
def store_result(result:Array<U32> & String) -> F.Store & String:
  match result:
    case (values,text):(F.Store{values},text)
def store(value:F.Store) -> F.Store & String:
  match value:
    case F.Store{values}:store_result(array(values))
def resource_result(+value:U32,result:Array<U32> & String) -> F.Resources & String:
  match result:
    case (retained,text):(F.Resources{retained,value},"resource("++text++","++U32.show(value)++")")
def resource(value:F.Resources) -> F.Resources & String:
  match value:
    case F.Resources{retained,value}:resource_result(value,array(retained))
def pending_tail(~S:Data,head:W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>,result:List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)> & Nat) -> List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)> & Nat:
  match result:
    case (rest,count):(head <> rest,1n+count)
def pending(~S:Data,items:List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)>) -> List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)> & Nat:
  match items:
    case []:([],0n)
    case head <> rest:pending_tail(~S,head,pending(~S,rest))
def live_result(result:Array<Bool> & Array<Bool>) -> Array<Bool> & String:
  match result:
    case (live,copy):(live,List.show(&1,Bool,bool_show,Array.to_list(~Bool,copy)))
def live(value:Array<Bool>) -> Array<Bool> & String:
  live_result(Array.clone(Bool,value))
def world_restored(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,result:((Array<Bool> & (F.Store & F.Resources)) & List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)>) & (String & Nat)) -> W.World<S,F.Store,F.Resources,Unit> & String:
  match result:
    case (((live,(store,resource)),pending),(text,count)):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"world("++U32.show(namespace)++","++U32.show(nextId)++","++U32.show(highWater)++","++U32.show(capacity)++","++Nat.show(depth)++","++text++",events="++Nat.show(List.length(&2,Unit,events))++",pending="++Nat.show(count)++","++List.show(&2,W.RegistrationMeta,registration,registrations)++","++U32.show(nextSystemId)++","++U32.show(clock)++")")
def world_pending(~S:Data,namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,result:((Array<Bool> & (F.Store & F.Resources)) & String) & (List<(W.World<S,F.Store,F.Resources,Unit> -> W.World<S,F.Store,F.Resources,Unit>)> & Nat)) -> W.World<S,F.Store,F.Resources,Unit> & String:
  match result:
    case ((owned,text),(pending,count)):world_restored(~S,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,((owned,pending),(text,count)))
def world(~S:Data,value:W.World<S,F.Store,F.Resources,Unit>) -> W.World<S,F.Store,F.Resources,Unit> & String:
  match value:
    case W.World{namespace,nextId,highWater,liveOwner,capacity,depth,storeOwner,resourceOwner,events,pendingOwner,registrations,nextSystemId,clock}:world_pending(~S,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,(pair(~Array<Bool>,~(F.Store & F.Resources),~live,~pair(~F.Store,~F.Resources,~store,~resource),(liveOwner,(storeOwner,resourceOwner))),pending(~S,pendingOwner)))
def app_observed(~S:Data,schema:Schema.Schema<S,F.Store,F.Resources>,recipe:Tree.Recipe<W.World<S,F.Store,F.Resources,Unit>,F.Rows(),F.observe(~S)>,+debug:Bool,+plans:List<&2,N.Named<S>>,result:(W.World<S,F.Store,F.Resources,Unit> & F.Owners(~S)) & String) -> F.application(~S) & String:
  match result:
    case ((world,owners),text):(N.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans},text++"/debug="++bool_show(debug)++"/plans="++List.show(&2,N.Named<S>,named(~S),plans))
def physical(~S:Data,value:F.application(~S)) -> F.application(~S) & String:
  match value:
    case N.Application{App.Application{schema,Build.Registered{worldOwner,ownersOwner,recipe,debug}},plans}:app_observed(~S,schema,recipe,debug,plans,pair(~W.World<S,F.Store,F.Resources,Unit>,~F.Owners(~S),~world(~S),~owners(~S),(worldOwner,ownersOwner)))
def access_category(item:Access.Category) -> String:
  match item:
    case Access.Components{}:"components"
    case Access.Resources{}:"resources"
    case Access.Events{}:"events"
    case Access.Services{}:"services"
def access_role(item:Access.Role) -> String:
  match item:
    case Access.Reader{}:"reader"
    case Access.Writer{}:"writer"
    case Access.Filter{}:"filter"
def access_use(item:Access.Use) -> String:
  match item:
    case Access.Use{namespace,id,name,kind,role}:"use("++U32.show(namespace)++","++U32.show(id)++","++quoted(name)++","++mode(kind)++","++access_role(role)++")"
def access_entry(item:Access.Entry) -> String:
  match item:
    case Access.Entry{category,key,uses}:"entry("++access_category(category)++","++quoted(key)++","++List.show(&2,Access.Use,access_use,uses)++")"
def plan_index(item:N.PlanIndex) -> String:
  match item:
    case N.PlanIndex{label,entries}:quoted(label)++":"++List.show(&2,Access.Entry,access_entry,entries)
def index(item:Maybe<&2,N.Index>) -> String:
  match item:
    case None{}:"none"
    case Some{N.Index{namespace,inventory,plans}}:"index("++U32.show(namespace)++","++List.show(&2,Access.Entry,access_entry,inventory)++","++List.show(&2,N.PlanIndex,plan_index,plans)++")"
