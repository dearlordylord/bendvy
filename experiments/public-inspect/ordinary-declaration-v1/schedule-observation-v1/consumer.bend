import Base
import ./schedule.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type A is Data: A{}
type B is Data: B{}
type State<S:Data> is Data:
  State{world:String,operational:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,requirements:List<&2,SP.Requirement<S>>,owners:List<&2,App.RegistryView>,enabled:Bool}
type Report<S:Data> is Data:
  Report{before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,repeated:Maybe<&2,App.Description<S>>,afterDescriptions:State<S>,result:Result<&2,&2,String,List<&2,Sch.Observation>>,afterRun:State<S>,postRun:Maybe<&2,App.Description<S>>}
  Refused{message:String}

def incremented(amount:U32,got:Array<U32> & U32) -> Array<U32> & Unit:
  match got:
    case (owner,value):(Array.set(U32,owner,0,(value + amount : U32)),Unit{})
def increment(+amount:U32,owner:Array<U32>) -> Array<U32> & Unit:
  incremented(amount,Array.get(U32,owner,0))
def world_incremented(~S:Data,result:W.World<S,Unit,Array<U32>,Unit> & Unit) -> W.World<S,Unit,Array<U32>,Unit>:
  match result:
    case (world,_):world
def add(~S:Data,~amount:U32,world:W.World<S,Unit,Array<U32>,Unit>) -> W.World<S,Unit,Array<U32>,Unit>:
  world_incremented(~S,W.observe_resource(~S,~Unit,~Array<U32>,~Unit,~Unit,~increment(amount),world))
def runner1(~S:Data,world:W.World<S,Unit,Array<U32>,Unit>,args:Unit) -> Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  Sys.Succeeded{add(~S,~10,world),Unit{}}
def runner2(~S:Data,world:W.World<S,Unit,Array<U32>,Unit>,args:Unit) -> Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  Sys.Succeeded{add(~S,~20,world),Unit{}}
def deferred(~S:Data,world:W.World<S,Unit,Array<U32>,Unit>) -> W.World<S,Unit,Array<U32>,Unit>:
  add(~S,~100,world)
def condition(~S:Data,world:W.World<S,Unit,Array<U32>,Unit>,id:U32) -> W.World<S,Unit,Array<U32>,Unit> & Bool:
  (add(~S,~1,world),U32.is_eq(id,1))
def empty(unit:Unit) -> Unit: Unit{}
def ordinary_plan(~S:Data,id1:U32,id2:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{id1,1},[SP.Resource{7}]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{id2,2},[SP.Resource{7},SP.Resource{7}]}}}}
# Fixture-only refusal transport, not a public generic scheduler policy.
def first_run(~S:Data,other:Sys.Registry<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner2(~S)>,result:Sys.RunResult<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner1(~S)>) -> App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(App.Pack{registry,other},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(App.Pack{registry,other},Sys.Failed{world,"fixture-registration-refused"})
def second_run(~S:Data,other:Sys.Registry<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner1(~S)>,result:Sys.RunResult<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner2(~S)>) -> App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(App.Pack{other,registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(App.Pack{other,registry},Sys.Failed{world,"fixture-registration-refused"})
def dispatch_selected(~S:Data,selected:Bool,first:Sys.Registry<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner1(~S)>,second:Sys.Registry<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner2(~S)>,world:W.World<S,Unit,Array<U32>,Unit>) -> App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  match selected:
    case True{}:first_run(~S,second,Sys.run_tracked(~S,~Unit,~Array<U32>,~Unit,~Unit,~String,~Unit,~runner1(~S),first,world,Unit{}))
    case False{}:second_run(~S,first,Sys.run_tracked(~S,~Unit,~Array<U32>,~Unit,~Unit,~String,~Unit,~runner2(~S),second,world,Unit{}))
def dispatch(~S:Data,owners:App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>,world:W.World<S,Unit,Array<U32>,Unit>,id:U32) -> App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Sys.Outcome<W.World<S,Unit,Array<U32>,Unit>,String,Unit>:
  match owners:
    case App.Pack{Sys.Registry{ns,+firstId,name,access,cursor},second}:dispatch_selected(~S,U32.is_eq(id,firstId),Sys.Registry{ns,firstId,name,access,cursor},second,world)
def pending_join(~S:Data,head:W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>,got:List<(W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>)> & Nat) -> List<(W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>)> & Nat:
  match got:
    case (rest,n):(head <> rest,1n+n)
def pending(~S:Data,items:List<(W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>)>) -> List<(W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>)> & Nat:
  match items:
    case []:([],0n)
    case head <> rest:pending_join(~S,head,pending(~S,rest))
def array_leaf(~T:Type,seen:T & String) -> Array<T> & String:
  match seen:
    case (value,text):(ALeaf{value},"leaf:" ++ text)
def array_node(~T:Type,left:Array<T> & String,right:Array<T> & String) -> Array<T> & String:
  match left right:
    case (l,a), (r,b):(ANode{l,r},"node(" ++ a ++ "," ++ b ++ ")")
def array_view(~T:Type,~project:T -> T & String,owner:Array<T>) -> Array<T> & String:
  match owner:
    case ALeaf{value}:array_leaf(~T,project(value))
    case ANode{left,right}:array_node(~T,array_view(~T,~project,left),array_view(~T,~project,right))
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def bool_view(value:Bool) -> Bool & String:
  bool_data(value)
def u32_view(value:U32) -> U32 & String:
  u32_data(value)
def metadata(x:W.RegistrationMeta) -> String:
  match x:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def world_parts(~S:Data,+ns:U32,+next:U32,+high:U32,+cap:U32,+depth:Nat,+events:List<&2,Unit>,+regs:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,liveSeen:Array<Bool> & String,resourceSeen:Array<U32> & String,pendingSeen:List<(W.World<S,Unit,Array<U32>,Unit> -> W.World<S,Unit,Array<U32>,Unit>)> & Nat) -> W.World<S,Unit,Array<U32>,Unit> & String:
  match liveSeen resourceSeen pendingSeen:
    case (live,liveText), (resource,resourceText), (commands,count):
      (W.World{ns,next,high,live,cap,depth,Unit{},resource,events,commands,regs,nextSystem,clock},String.join([U32.show(ns),U32.show(next),U32.show(high),liveText,U32.show(cap),Nat.show(depth),"Unit",resourceText,List.show(&2,Unit,x => "Unit",events),Nat.show(count),List.show(&2,W.RegistrationMeta,metadata,regs),U32.show(nextSystem),U32.show(clock)],"|"))
def world_view(~S:Data,world:W.World<S,Unit,Array<U32>,Unit>) -> W.World<S,Unit,Array<U32>,Unit> & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,_,resource,events,commands,regs,nextSystem,clock}:world_parts(~S,ns,next,high,cap,depth,events,regs,nextSystem,clock,array_view(~Bool,~bool_view,live),array_view(~U32,~u32_view,resource),pending(~S,commands))
def seen(~S:Data,+plan:SP.Plan<S>,+ns:U32,+name:String,+steps:List<&2,Sch.Step>,+needs:List<&2,SP.Requirement<S>>,+enabled:Bool,owners:App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>,result:W.World<S,Unit,Array<U32>,Unit> & String) -> App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & State<S>:
  match owners result:
    case App.Pack{Sys.Registry{+n1,+i1,+s1,+a1,+c1},Sys.Registry{+n2,+i2,+s2,+a2,+c2}}, (world,text):
      (App.Application{world,plan,SP.Provisioned{Sch.Schedule{ns,name,steps,App.Pack{Sys.Registry{n1,i1,s1,a1,c1},Sys.Registry{n2,i2,s2,a2,c2}}},needs},enabled},State{text,plan,ns,name,steps,needs,[App.RegistryView{n1,i1,s1,a1,c1},App.RegistryView{n2,i2,s2,a2,c2}],enabled})

def observe(~S:Data,app:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>) -> App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & State<S>:
  match app:
    case App.Application{world,plan,SP.Provisioned{Sch.Schedule{ns,name,steps,owners},needs},enabled}:seen(~S,plan,ns,name,steps,needs,enabled,owners,world_view(~S,world))
def final_snapshot(~S:Data,before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,repeated:Maybe<&2,App.Description<S>>,after:State<S>,outcome:Result<&2,&2,String,List<&2,Sch.Observation>>,text:State<S>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Maybe<&2,App.Description<S>>) -> Report<S>:
  match done:
    case (_,post):Report{before,disabled,enabled,repeated,after,outcome,text,post}
def final(~S:Data,before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,repeated:Maybe<&2,App.Description<S>>,after:State<S>,outcome:Result<&2,&2,String,List<&2,Sch.Observation>>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & State<S>) -> Report<S>:
  match done:
    case (app,text):final_snapshot(~S,before,disabled,enabled,repeated,after,outcome,text,App.snapshot(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),app))
def ran(~S:Data,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,repeated:Maybe<&2,App.Description<S>>,after:State<S>,result:Sch.RunResult<S,Unit,Array<U32>,Unit,App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>,String>) -> Report<S>:
  match result:
    case Sch.Finished{schedule,world,observations}:final(~S,before,disabled,enabled,repeated,after,Done{observations},observe(~S,App.Application{world,plan,SP.Provisioned{schedule,needs},True{}}))
    case _:Refused{"fixture-schedule-nonfinished"}
def execute_after(~S:Data,before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,repeated:Maybe<&2,App.Description<S>>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & State<S>) -> Report<S>:
  match done:
    case (App.Application{world,plan,SP.Provisioned{schedule,needs},_},after):ran(~S,plan,needs,before,disabled,enabled,repeated,after,Sch.run(~S,~Unit,~Array<U32>,~Unit,~App.Pack<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>,~String,~dispatch(~S),~condition(~S),schedule,world))
def second_snapshot(~S:Data,before:State<S>,disabled:Maybe<&2,App.Description<S>>,enabled:Maybe<&2,App.Description<S>>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Maybe<&2,App.Description<S>>) -> Report<S>:
  match done:
    case (app,repeated):execute_after(~S,before,disabled,enabled,repeated,observe(~S,app))
def first_snapshot(~S:Data,before:State<S>,disabled:Maybe<&2,App.Description<S>>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Maybe<&2,App.Description<S>>) -> Report<S>:
  match done:
    case (app,enabled):second_snapshot(~S,before,disabled,enabled,App.snapshot(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),app))
def disabled_snapshot(~S:Data,before:State<S>,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & Maybe<&2,App.Description<S>>) -> Report<S>:
  match done:
    case (app,disabled):first_snapshot(~S,before,disabled,App.snapshot(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),App.enable(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),app,True{})))
def initial(~S:Data,done:App.Application<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)> & State<S>) -> Report<S>:
  match done:
    case (app,before):disabled_snapshot(~S,before,App.snapshot(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),app))
def built(~S:Data,result:App.Build<S,Unit,Array<U32>,Unit,runner1(~S),runner2(~S)>) -> Report<S>:
  match result:
    case App.Built{app}:initial(~S,observe(~S,app))
    case _:Refused{"fixture-build-invalid"}
def second_registered(~S:Data,first:Sys.Registry<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner1(~S)>,result:Sys.RegistrationResult<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner2(~S)>) -> Report<S>:
  match result:
    case Sys.Registered{world,second}:built(~S,App.build(~S,~Unit,~Array<U32>,~Unit,~runner1(~S),~runner2(~S),~ordinary_plan(~S),W.enqueue(~S,~Unit,~Array<U32>,~Unit,world,deferred(~S)),"OrdinaryUpdate",False{},App.Pack{first,second}))
    case _:Refused{"fixture-second-registration"}
def first_registered(~S:Data,result:Sys.RegistrationResult<S,Unit,Array<U32>,Unit,Unit,String,Unit,runner1(~S)>) -> Report<S>:
  match result:
    case Sys.Registered{world,first}:second_registered(~S,first,Sys.register(~S,~Unit,~Array<U32>,~Unit,~Unit,~String,~Unit,~runner2(~S),world,"CounterSkipped",["counter"]))
    case _:Refused{"fixture-first-registration"}
def created(~S:Data,result:W.Creation<S,Unit,Array<U32>,Unit>) -> Report<S>:
  match result:
    case W.Created{_,world}:first_registered(~S,Sys.register(~S,~Unit,~Array<U32>,~Unit,~Unit,~String,~Unit,~runner1(~S),world,"CounterRuns",["counter"]))
    case _:Refused{"fixture-create"}
def setup(~S:Data) -> Report<S>:
  created(~S,W.create(~S,~Unit,~Array<U32>,~Unit,~empty,W.factory(),Array.new(U32,0n,0)))
def main() -> Report<A> & Report<B>:
  (setup(~A),setup(~B))
