import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/capabilities.bend as Cap

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Token is Data:
  Token{}
type Slot is Type:
  Missing{}
  Ready{owner:Array<U32>}
  Incompatible{owner:Array<U32>}
type OtherStore is Type:
  OtherStore{column:Col.Column<Other,Array<U32>>}
type FamilyProvision is Data:
  AbsentFamily{}
  DeclaredFamily{descriptor:C.Family<Schema,Store,Rest,Array<U32>,List<&2,U32>,Token,take,put,projected>}
  WrongFamily{descriptor:C.Family<Other,OtherStore,Unit,Array<U32>,List<&2,U32>,Token,take_other,put_other,projected>}
type Store is Type:
  Store{column:Col.Column<Schema,Array<U32>>,family:FamilyProvision,writes:U32}
type Rest is Data:
  Rest{family:FamilyProvision,writes:U32}
type Resources is Type:
  Resources{resource:Slot,service:Slot,resourceWrites:U32,hostCalls:U32,conditionCalls:U32,retired:List<Array<U32>>,trace:List<&2,U32>}
type Owners is Type:
  Owners{a:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>,b:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>}
def take(store:Store) -> Rest & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{column,family,writes}: (Rest{family,writes},column)
def put(rest:Rest,column:Col.Column<Schema,Array<U32>>) -> Store:
  match rest:
    case Rest{family,writes}: Store{column,family,writes}
def projected_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,U32,a,b))

def projected(values:Array<U32>) -> Array<U32> & List<&2,U32>:
  match values:
    case ALeaf{+a}: (ALeaf{a},[a])
    case ANode{left,right}: projected_join(projected(left),projected(right))
def take_other(store:OtherStore) -> Unit & Col.Column<Other,Array<U32>>:
  match store:
    case OtherStore{column}: (Unit{},column)
def put_other(_:Unit,column:Col.Column<Other,Array<U32>>) -> OtherStore:
  OtherStore{column}
def other_family() -> C.Family<Other,OtherStore,Unit,Array<U32>,List<&2,U32>,Token,take_other,put_other,projected>:
  C.Family{"other-cells"}
def family_code(value:FamilyProvision) -> U32:
  match value:
    case AbsentFamily{}: 0
    case DeclaredFamily{_}: 1
    case WrongFamily{_}: 2
def family() -> C.Family<Schema,Store,Rest,Array<U32>,List<&2,U32>,Token,take,put,projected>:
  C.Family{"cells"}
def empty(_:Unit) -> Store:
  Store{Col.Column{ALeaf{Some{ANode{ALeaf{10},ALeaf{99}}}},[]},DeclaredFamily{family()},0}
def slot(mode:U32,+value:U32) -> Slot:
  match mode:
    case 0: Missing{}
    case 1: Ready{ANode{ALeaf{value},ALeaf{(value+100:U32)}}}
    case _: Incompatible{ANode{ALeaf{value},ALeaf{(value+100:U32)}}}
def resource_start(mode:U32) -> Resources:
  match mode:
    case 1: Resources{slot(0,20),slot(1,30),0,0,0,[],[]}
    case 2: Resources{slot(2,20),slot(1,30),0,0,0,[],[]}
    case 3: Resources{slot(1,20),slot(0,30),0,0,0,[],[]}
    case 4: Resources{slot(1,20),slot(2,30),0,0,0,[],[]}
    case 11: Resources{slot(0,20),slot(0,30),0,0,0,[],[]}
    case _: Resources{slot(1,20),slot(1,30),0,0,0,[],[]}
def service(value:Slot,+calls:U32) -> Slot & U32:
  match value:
    case Ready{owner}: (Ready{owner},U32.add(calls,1))
    case value: (value,calls)
def resource_mutated(owner:Array<U32>,+count:U32,+id:U32) -> Slot & U32:
  (Ready{Array.set(U32,owner,0,id)},U32.add(count,1))
def resource_write(value:Slot,count:U32,id:U32) -> Slot & U32:
  match value:
    case Ready{owner}: resource_mutated(owner,count,id)
    case value: (value,count)
def complete_side_effects(world:W.World<Schema,Store,Resources,U32>,+id:U32,r:Slot & U32,s:Slot & U32,conditions:U32,retired:List<Array<U32>>,+trace:List<&2,U32>) -> W.World<Schema,Store,Resources,U32>:
  match world r s:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,_,+events,pending,+registrations,+nextSystem,+clock}, (resource,writes), (host,calls): W.enqueue(~Schema,~Store,~Resources,~U32,W.event_publish(~Schema,~Store,~Resources,~U32,W.World{ns,next,high,live,cap,depth,store,Resources{resource,host,writes,calls,conditions,retired,List.append(&2,U32,trace,[id])},events,pending,registrations,nextSystem,clock},[id]),w => w)
def effects(world:W.World<Schema,Store,Resources,U32>,+id:U32,old:Maybe<&1,Array<U32>>) -> W.World<Schema,Store,Resources,U32>:
  match world old:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,+family,+writes},Resources{resource,host,rwrites,calls,conditions,retired,+trace},+events,pending,+registrations,+nextSystem,+clock}, Some{old}: complete_side_effects(W.World{ns,next,high,live,cap,depth,Store{column,family,U32.add(writes,1)},Resources{Missing{},Missing{},0,0,0,[],[]},events,pending,registrations,nextSystem,clock},id,resource_write(resource,rwrites,id),service(host,calls),conditions,old <> retired,trace)
    case world None{}: world
def replaced(result:C.Replacement<W.World<Schema,Store,Resources,U32>,Array<U32>>,+id:U32) -> Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  match result:
    case C.Replaced{world,old}: Sys.Succeeded{effects(world,id,old),Unit{}}
    case C.ReplaceRejected{world,incoming,_}: Sys.Failed{world,"component-rejected"}
def runner_value(world:W.World<Schema,Store,Resources,U32>,+id:U32) -> Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  replaced(C.replace(~Schema,~Store,~Resources,~U32,~Rest,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~projected,family(),world,W.Handle{1,1},Some{ANode{ALeaf{id},ALeaf{99}}}),id)
def runner(world:W.World<Schema,Store,Resources,U32>,id:U32) -> Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  runner_value(world,id)
def result_a(result:Sys.RunResult<Schema,Store,Resources,U32,U32,String,Unit,runner>,b:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>) -> Owners & Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  match result:
    case Sys.Completed{a,outcome}: (Owners{a,b},outcome)
    case Sys.RegistrationRejected{a,world,_}: (Owners{a,b},Sys.Failed{world,"registration"})
def result_b(result:Sys.RunResult<Schema,Store,Resources,U32,U32,String,Unit,runner>,a:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>) -> Owners & Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  match result:
    case Sys.Completed{b,outcome}: (Owners{a,b},outcome)
    case Sys.RegistrationRejected{b,world,_}: (Owners{a,b},Sys.Failed{world,"registration"})
def dispatch_value(owners:Owners,world:W.World<Schema,Store,Resources,U32>,+id:U32) -> Owners & Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  match owners id:
    case Owners{a,b} 1: result_a(Sys.run(~Schema,~Store,~Resources,~U32,~U32,~String,~Unit,~runner,a,world,id),b)
    case Owners{a,b} 2: result_b(Sys.run(~Schema,~Store,~Resources,~U32,~U32,~String,~Unit,~runner,b,world,id),a)
    case owners _: (owners,Sys.Failed{world,"unknown"})
def dispatch(owners:Owners,world:W.World<Schema,Store,Resources,U32>,id:U32) -> Owners & Sys.Outcome<W.World<Schema,Store,Resources,U32>,String,Unit>:
  dispatch_value(owners,world,id)
def condition_value(world:W.World<Schema,Store,Resources,U32>,+slot:U32) -> W.World<Schema,Store,Resources,U32> & Bool:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Resources{resource,host,writes,calls,conditions,retired,trace},+events,pending,+registrations,+nextSystem,+clock}: (W.World{ns,next,high,live,cap,depth,store,Resources{resource,host,writes,calls,U32.add(conditions,1),retired,trace},events,pending,registrations,nextSystem,clock},U32.is_gt(slot,0))
def condition(world:W.World<Schema,Store,Resources,U32>,slot:U32) -> W.World<Schema,Store,Resources,U32> & Bool:
  condition_value(world,slot)
def families(compatible:FamilyProvision) -> List<&2,P.Requirement<Schema>>:
  match compatible:
    case DeclaredFamily{_}: [P.Component{1}]
    case _: []
def available_slots(family:FamilyProvision,resource:Slot,host:Slot) -> (Slot & Slot) & List<&2,P.Requirement<Schema>>:
  match resource host:
    case Ready{r} Ready{s}: ((Ready{r},Ready{s}),List.append(&2,P.Requirement<Schema>,[P.Resource{1},P.Service{1}],families(family)))
    case Ready{r} host: ((Ready{r},host),List.append(&2,P.Requirement<Schema>,[P.Resource{1}],families(family)))
    case resource Ready{s}: ((resource,Ready{s}),List.append(&2,P.Requirement<Schema>,[P.Service{1}],families(family)))
    case resource host: ((resource,host),families(family))
def provisioned(world:W.World<Schema,Store,Resources,U32>,observed:(Slot & Slot) & List<&2,P.Requirement<Schema>>) -> W.World<Schema,Store,Resources,U32> & List<&2,P.Requirement<Schema>>:
  match world observed:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Resources{_,_,writes,calls,conditions,retired,trace},+events,pending,+registrations,+nextSystem,+clock}, ((resource,host),available): (W.World{ns,next,high,live,cap,depth,store,Resources{resource,host,writes,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock},available)
def provision(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32> & List<&2,P.Requirement<Schema>>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,+family,+cwrites},Resources{resource,host,writes,calls,conditions,retired,trace},+events,pending,+registrations,+nextSystem,+clock}: provisioned(W.World{ns,next,high,live,cap,depth,Store{column,family,cwrites},Resources{Missing{},Missing{},writes,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock},available_slots(family,resource,host))
def requirement(item:P.Requirement<Schema>) -> String:
  match item:
    case P.Component{id}: "C" ++ U32.show(id)
    case P.Resource{id}: "R" ++ U32.show(id)
    case P.Service{id}: "S" ++ U32.show(id)
def needs(items:List<&2,P.Requirement<Schema>>) -> String:
  match items:
    case []: ""
    case item <> rest: requirement(item) ++ "," ++ needs(rest)
def observations(items:List<&2,Sch.Observation>) -> String:
  match items:
    case []: ""
    case Sch.Entered{name} <> rest: "phase:" ++ name ++ ";" ++ observations(rest)
    case Sch.Ran{id} <> rest: "run:" ++ U32.show(id) ++ ";" ++ observations(rest)
    case Sch.Skipped{id} <> rest: "skip:" ++ U32.show(id) ++ ";" ++ observations(rest)
    case Sch.Applied{} <> rest: "barrier;" ++ observations(rest)
def texts(items:List<&2,String>) -> String:
  match items:
    case []: ""
    case item <> rest: item ++ "," ++ texts(rest)
def registry(owner:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>) -> Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner> & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ texts(access) ++ ":" ++ U32.show(cursor))
def owners_join(a:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner> & String,b:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner> & String) -> Owners & String:
  (a,x)=a
  (b,y)=b
  (Owners{a,b},x ++ "/" ++ y)
def owner_snapshot(value:Owners) -> Owners & String:
  match value:
    case Owners{a,b}: owners_join(registry(a),registry(b))
def slot_projected(~wrap:Array<U32> -> Slot,result:Array<U32> & List<&2,U32>) -> Slot & String:
  (owner,values)=result
  (wrap(owner),List.show(&2,U32,U32.show,values))
def ready(owner:Array<U32>) -> Slot:
  Ready{owner}
def bad(owner:Array<U32>) -> Slot:
  Incompatible{owner}
def incompatible_snapshot(observed:Slot & String) -> Slot & String:
  (owner,text)=observed
  (owner,"incompatible:" ++ text)
def slot_snapshot(value:Slot) -> Slot & String:
  match value:
    case Missing{}: (Missing{},"missing")
    case Ready{owner}: slot_projected(~ready,projected(owner))
    case Incompatible{owner}: incompatible_snapshot(slot_projected(~bad,projected(owner)))
def queue_join(head:W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>,tail:List<(W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>)> & U32) -> List<(W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>)> & U32:
  (tail,n)=tail
  (head <> tail,U32.add(n,1))
def queue_count(commands:List<(W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>)>) -> List<(W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>)> & U32:
  match commands:
    case []: ([],0)
    case command <> rest: queue_join(command,queue_count(rest))
def retired_join(head:Array<U32> & List<&2,U32>,tail:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & List<&2,String>:
  (owner,cells)=head
  (tail,views)=tail
  (owner <> tail,Con{List.show(&2,U32,U32.show,cells),views})
def retired_snapshot(owners:List<Array<U32>>) -> List<Array<U32>> & List<&2,String>:
  match owners:
    case []: ([],[])
    case owner <> rest: retired_join(projected(owner),retired_snapshot(rest))
def string_identity(value:String) -> String:
  value
def world_snapshot_join(world:W.World<Schema,Store,Resources,U32>,slots:(Slot & String) & (Slot & String),component:Col.Column<Schema,Array<U32>> & Maybe<&2,List<&2,U32>>,+prefix:String,queue:List<(W.World<Schema,Store,Resources,U32> -> W.World<Schema,Store,Resources,U32>)> & U32,oldOwners:List<Array<U32>> & List<&2,String>) -> W.World<Schema,Store,Resources,U32> & String:
  match world slots component queue oldOwners:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{_,+family,+cwrites},Resources{_,_,+rwrites,+calls,+conditions,_,+trace},+events,_,+registrations,+nextSystem,+clock}, ((resource,rtext),(host,stext)), (column,None{}), (pending,+queued), (retired,+oldCells): (W.World{ns,next,high,live,cap,depth,Store{column,family,cwrites},Resources{resource,host,rwrites,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock},prefix ++ ";retired=" ++ List.show(&2,String,string_identity,oldCells) ++ ";cell=" ++ "absent" ++ ";resource=" ++ rtext ++ ";service=" ++ stext ++ ";cw=" ++ U32.show(cwrites) ++ ";rw=" ++ U32.show(rwrites) ++ ";host=" ++ U32.show(calls) ++ ";conditions=" ++ U32.show(conditions) ++ ";clock=" ++ U32.show(clock) ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";queue=" ++ U32.show(queued) ++ ";trace=" ++ List.show(&2,U32,U32.show,trace))
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{_,+family,+cwrites},Resources{_,_,+rwrites,+calls,+conditions,_,+trace},+events,_,+registrations,+nextSystem,+clock}, ((resource,rtext),(host,stext)), (column,Some{+cells}), (pending,+queued), (retired,+oldCells): (W.World{ns,next,high,live,cap,depth,Store{column,family,cwrites},Resources{resource,host,rwrites,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock},prefix ++ ";retired=" ++ List.show(&2,String,string_identity,oldCells) ++ ";cell=" ++ List.show(&2,U32,U32.show,cells) ++ ";resource=" ++ rtext ++ ";service=" ++ stext ++ ";cw=" ++ U32.show(cwrites) ++ ";rw=" ++ U32.show(rwrites) ++ ";host=" ++ U32.show(calls) ++ ";conditions=" ++ U32.show(conditions) ++ ";clock=" ++ U32.show(clock) ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";queue=" ++ U32.show(queued) ++ ";trace=" ++ List.show(&2,U32,U32.show,trace))
def world_snapshot(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32> & String:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,+family,+cwrites},Resources{resource,host,+rwrites,+calls,+conditions,retired,+trace},+events,pending,+registrations,+nextSystem,+clock}: world_snapshot_join(W.World{ns,next,high,live,cap,depth,Store{Col.Column{ALeaf{None{}},[]},family,cwrites},Resources{Missing{},Missing{},rwrites,calls,conditions,[],trace},events,[],registrations,nextSystem,clock},(slot_snapshot(resource),slot_snapshot(host)),Col.view(~Schema,~Array<U32>,~List<&2,U32>,~projected,column,1),"family=" ++ U32.show(family_code(family)),queue_count(pending),retired_snapshot(retired))
def repaired_slot(value:Slot,+fresh:U32) -> Slot:
  match value:
    case Missing{}: Ready{ANode{ALeaf{fresh},ALeaf{(fresh+100:U32)}}}
    case Ready{owner}: Ready{owner}
    case Incompatible{owner}: Ready{owner}
def repair(world:W.World<Schema,Store,Resources,U32>) -> W.World<Schema,Store,Resources,U32>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,_,writes},Resources{resource,host,rwrites,calls,conditions,retired,trace},+events,pending,+registrations,+nextSystem,+clock}: W.World{ns,next,high,live,cap,depth,Store{column,DeclaredFamily{family()},writes},Resources{repaired_slot(resource,20),repaired_slot(host,30),rwrites,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock}
def schedule_join(+ns:U32,+name:String,+steps:List<&2,Sch.Step>,owners:Owners & String) -> Sch.Schedule<Schema,Store,Resources,U32,Owners> & String:
  (owners,text)=owners
  (Sch.Schedule{ns,name,steps,owners},name ++ ":" ++ U32.show(ns) ++ ":" ++ text)

def schedule_snapshot(value:Sch.Schedule<Schema,Store,Resources,U32,Owners>) -> Sch.Schedule<Schema,Store,Resources,U32,Owners> & String:
  match value:
    case Sch.Schedule{+ns,+name,+steps,owners}: schedule_join(ns,name,steps,owner_snapshot(owners))
def result_snapshot(+label:String,schedule:Sch.Schedule<Schema,Store,Resources,U32,Owners> & String,world:W.World<Schema,Store,Resources,U32> & String) -> String:
  (_,owners)=schedule
  (_,text)=world
  label ++ "|owners=" ++ owners ++ "|" ++ text

def finished(result:Sch.RunResult<Schema,Store,Resources,U32,Owners,String>,+requirements:List<&2,P.Requirement<Schema>>) -> String:
  match result:
    case Sch.Finished{schedule,world,obs}: result_snapshot("ok:" ++ observations(obs) ++ ":needs=" ++ needs(requirements),schedule_snapshot(schedule),world_snapshot(world))
    case Sch.Failed{schedule,world,error,obs}: result_snapshot("failed:" ++ error ++ ":" ++ observations(obs),schedule_snapshot(schedule),world_snapshot(world))
    case Sch.Rejected{schedule,world}: result_snapshot("rejected",schedule_snapshot(schedule),world_snapshot(world))
def retry_result(result:P.ProvisionResult<Schema,Store,Resources,U32,Owners,String>) -> String:
  match result:
    case P.Executed{result,needs}: finished(result,needs)
    case P.Missing{_,_,item}: "still-missing:" ++ needs(item)
def refusal_observed(schedule:Sch.Schedule<Schema,Store,Resources,U32,Owners> & String,world:W.World<Schema,Store,Resources,U32> & String,+requirements:List<&2,P.Requirement<Schema>>,+missing:List<&2,P.Requirement<Schema>>) -> String:
  (schedule,ownertext)=schedule
  (world,text)=world
  "missing:" ++ needs(missing) ++ ":needs=" ++ needs(requirements) ++ "|owners=" ++ ownertext ++ "|" ++ text ++ "\nretry|" ++ retry_result(P.run(~Schema,~Store,~Resources,~U32,~Owners,~String,~dispatch,~condition,~provision,P.Provisioned{schedule,requirements},repair(world)))
def provision_result(result:P.ProvisionResult<Schema,Store,Resources,U32,Owners,String>) -> String:
  match result:
    case P.Executed{result,needs}: finished(result,needs)
    case P.Missing{P.Provisioned{schedule,needs},world,missing}: refusal_observed(schedule_snapshot(schedule),world_snapshot(world),needs,missing)
def nested(mode:U32) -> P.Plan<Schema>:
  match mode:
    case 7: P.Sequence{P.Entry{Sch.System{1,1},[P.Resource{1},P.Service{1},P.Component{1}]},P.Sequence{P.Empty{},P.Entry{Sch.System{1,1},[P.Resource{1}]}}}
    case 8: P.Sequence{P.Entry{Sch.Phase{"before"},[]},P.Sequence{P.Empty{},P.Entry{Sch.System{2,0},[P.Service{1},P.Resource{1},P.Component{1}]}}}
    case 10: P.Entry{Sch.Phase{"family-only"},[P.Component{1}]}
    case 9: P.Sequence{P.Empty{},P.Sequence{P.Entry{Sch.Phase{"empty"},[]},P.Empty{}}}
    case _: P.Sequence{P.Entry{Sch.Phase{"before"},[]},P.Sequence{P.Sequence{P.Entry{Sch.System{1,1},[P.Service{1},P.Resource{1},P.Component{1},P.Service{1}]},P.Empty{}},P.Sequence{P.Entry{Sch.Phase{"inner"},[]},P.Entry{Sch.System{2,1},[P.Component{1},P.Resource{1},P.Service{1}]}}}}
def invalid_snapshot(owners:Owners & String,world:W.World<Schema,Store,Resources,U32> & String) -> String:
  (_,owners)=owners
  (_,text)=world
  "invalid|owners=" ++ owners ++ "|" ++ text
def built(result:P.Build<Schema,Store,Resources,U32,Owners>,world:W.World<Schema,Store,Resources,U32>) -> String:
  match result:
    case P.Invalid{owners}: invalid_snapshot(owner_snapshot(owners),world_snapshot(world))
    case P.Built{schedule}: provision_result(P.run(~Schema,~Store,~Resources,~U32,~Owners,~String,~dispatch,~condition,~provision,schedule,world))
def start_b(result:Sys.RegistrationResult<Schema,Store,Resources,U32,U32,String,Unit,runner>,a:Sys.Registry<Schema,Store,Resources,U32,U32,String,Unit,runner>,mode:U32) -> String:
  match result:
    case Sys.Registered{world,b}: built(P.build(~Schema,~Store,~Resources,~U32,~Owners,1,"nested",nested(mode),[1,2],Owners{a,b}),world)
    case Sys.RegistrationFailed{_}: "registration-failed"
def start_a(result:Sys.RegistrationResult<Schema,Store,Resources,U32,U32,String,Unit,runner>,mode:U32) -> String:
  match result:
    case Sys.Registered{world,a}: start_b(Sys.register(~Schema,~Store,~Resources,~U32,~U32,~String,~Unit,~runner,world,"B",["component.write","resource.write","service.call","event.write","commands"]),a,mode)
    case Sys.RegistrationFailed{_}: "registration-failed"
def activated(result:W.World<Schema,Store,Resources,U32> & W.Status,mode:U32) -> String:
  (world,_)=result
  start_a(Sys.register(~Schema,~Store,~Resources,~U32,~U32,~String,~Unit,~runner,world,"A",["component.write","resource.write","service.call","event.write","commands"]),mode)
def reserved(result:W.World<Schema,Store,Resources,U32> & W.Reservation<Schema>,mode:U32) -> String:
  match result:
    case (world,W.Reserved{handle}): activated(W.activate(~Schema,~Store,~Resources,~U32,world,handle),mode)
    case (_, _): "reserve-rejected"
def configure(world:W.World<Schema,Store,Resources,U32>,+mode:U32) -> W.World<Schema,Store,Resources,U32>:
  match world mode:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,_,writes},resource,+events,pending,+registrations,+nextSystem,+clock} 5: W.World{ns,next,high,live,cap,depth,Store{column,AbsentFamily{},writes},resource,events,pending,registrations,nextSystem,clock}
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,_,writes},resource,+events,pending,+registrations,+nextSystem,+clock} 6: W.World{ns,next,high,live,cap,depth,Store{column,WrongFamily{other_family()},writes},resource,events,pending,registrations,nextSystem,clock}
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Resources{resource,host,writes,calls,conditions,retired,trace},+events,pending,+registrations,+nextSystem,+clock} 8: W.World{ns,next,high,live,cap,depth,store,Resources{resource,Missing{},writes,calls,conditions,retired,trace},events,pending,registrations,nextSystem,clock}
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{column,+family,+writes},resource,+events,pending,+registrations,+nextSystem,+clock} 10: W.World{ns,next,high,live,cap,depth,Store{Col.Column{ALeaf{None{}},[]},family,writes},resource,events,pending,registrations,nextSystem,clock}
    case world _: world
def created(result:W.Creation<Schema,Store,Resources,U32>,+mode:U32) -> String:
  match result:
    case W.Created{_,world}: reserved(W.reserve_id(~Schema,~Store,~Resources,~U32,configure(world,mode)),mode)
    case W.CreateRejected{_,_}: "create-rejected"
def scenario(+mode:U32) -> String:
  created(W.create(~Schema,~Store,~Resources,~U32,~empty,W.factory(),resource_start(mode)),mode)
def main() -> IO(Unit):
  IO.print("case0|" ++ scenario(0) ++ "\ncase1|" ++ scenario(1) ++ "\ncase2|" ++ scenario(2) ++ "\ncase3|" ++ scenario(3) ++ "\ncase4|" ++ scenario(4) ++ "\ncase5|" ++ scenario(5) ++ "\ncase6|" ++ scenario(6) ++ "\ncase7|" ++ scenario(7) ++ "\ncase8|" ++ scenario(8) ++ "\ncase9|" ++ scenario(9) ++ "\ncase10|" ++ scenario(10) ++ "\ncase11|" ++ scenario(11))
