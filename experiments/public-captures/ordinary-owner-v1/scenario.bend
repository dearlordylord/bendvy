import Base
import ./payload.bend as P
import ./system.bend as Sys
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/captures.bend as Capture
import ../../../src/ecs/ordinary-captures.bend as Entry
import ../../../src/ecs/ordinary-app-local-fields.bend as Ord

type Live is Data:
  Leaf{value:Bool}
  Node{left:Live,right:Live}
type WorldView is Data:
  WorldView{namespace:U32,nextId:U32,highWater:U32,live:Live,capacity:U32,depth:Nat,resource:U32,events:List<&2,Unit>,pending:U32,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:U32}
type OwnerView is Data:
  OwnerView{namespace:U32,id:U32,name:String,access:List<&2,String>,capture:P.Observation}
type Status is Data:
  Registered{}
  Success{}
  Failure{error:Sys.Error}
  Skipped{}
  Refused{args:Sys.Args}
  Removed{capture:P.Observation,oldId:U32,stillRegistered:Bool}
  Broken{location:String}
type Snapshot is Data:
  Snapshot{label:String,status:Status,world:WorldView,foreign:WorldView,first:OwnerView,second:OwnerView}
type State<S:Data> is Type:
  State{world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,first:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>}
def live_join(a:Array<Bool> & Live,b:Array<Bool> & Live) -> Array<Bool> & Live:
  match a b:
    case (left,x), (right,y):(ANode{left,right},Node{x,y})
def live(array:Array<Bool>) -> Array<Bool> & Live:
  match array:
    case ALeaf{+value}:(ALeaf{value},Leaf{value})
    case ANode{left,right}:live_join(live(left),live(right))
def world_live(~S:Data,+ns:U32,+next:U32,+high:U32,+cap:U32,+depth:Nat,+resource:U32,+events:List<&2,Unit>,pending:List<(W.World<S,Unit,U32,Unit> -> W.World<S,Unit,U32,Unit>)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,count:U32,result:Array<Bool> & Live) -> W.World<S,Unit,U32,Unit> & WorldView:
  (array,tree) = result
  (W.World{ns,next,high,array,cap,depth,Unit{},resource,events,pending,regs,sid,clock},WorldView{ns,next,high,tree,cap,depth,resource,events,count,regs,sid,clock})
def world_counted(~S:Data,result:W.World<S,Unit,U32,Unit> & U32) -> W.World<S,Unit,U32,Unit> & WorldView:
  match result:
    case (W.World{ns,next,high,array,cap,depth,_,resource,events,pending,regs,sid,clock},count):world_live(~S,ns,next,high,cap,depth,resource,events,pending,regs,sid,clock,count,live(array))
def world_view(~S:Data,world:W.World<S,Unit,U32,Unit>) -> W.World<S,Unit,U32,Unit> & WorldView:
  world_counted(~S,W.pending_count(~S,~Unit,~U32,~Unit,world))
def owner_returned(~S:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,result:P.Pack & P.Observation) -> L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & OwnerView:
  (pack,view) = result
  (L.Instance{ns,id,name,access,pack},OwnerView{ns,id,name,access,view})
def owner_view(~S:Data,instance:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & OwnerView:
  match instance:
    case L.Instance{ns,id,name,access,pack}:owner_returned(~S,ns,id,name,access,P.project(pack))
def snap_finish(~S:Data,label:String,status:Status,trace:List<&2,Snapshot>,a:W.World<S,Unit,U32,Unit> & WorldView,b:W.World<S,Unit,U32,Unit> & WorldView,x:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & OwnerView,y:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & OwnerView) -> State<S>:
  match a b x y:
    case (world,w), (foreign,f), (first,p), (second,q):State{world,foreign,first,second,List.append(&2,Snapshot,trace,[Snapshot{label,status,w,f,p,q}])}
def snapshot(~S:Data,label:String,status:Status,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,first,second,trace}:snap_finish(~S,label,status,trace,world_view(~S,world),world_view(~S,foreign),owner_view(~S,first),owner_view(~S,second))
def ran(~S:Data,label:String,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,result:L.Run<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> State<S>:
  match result:
    case L.Completed{world,first,Done{_}}:snapshot(~S,label,Success{},State{world,foreign,first,second,trace})
    case L.Completed{world,first,Fail{error}}:snapshot(~S,label,Failure{error},State{world,foreign,first,second,trace})
    case L.Refused{world,first,args}:snapshot(~S,label,Refused{args},State{world,foreign,first,second,trace})
def run(~S:Data,label:String,args:Sys.Args,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,first,second,trace}:ran(~S,label,foreign,second,trace,Capture.run(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first,world,args))
def swap(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,first,second,trace}:State{world,foreign,second,first,trace}
def skip(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,first,second,trace}:snapshot(~S,"skip",Skipped{},State{world,foreign,Capture.skip(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first),second,trace})
def foreign_ran(~S:Data,world:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,result:L.Run<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> State<S>:
  match result:
    case L.Refused{foreign,first,args}:snapshot(~S,"foreign",Refused{args},State{world,foreign,first,second,trace})
    case L.Completed{foreign,first,_}:snapshot(~S,"foreign",Broken{"foreign accepted"},State{world,foreign,first,second,trace})
def foreign_run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,first,second,trace}:foreign_ran(~S,world,second,trace,Capture.run(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first,foreign,Sys.Args{99,False{}}))
def define(~S:Data,world:W.World<S,Unit,U32,Unit>,name:String,pack:P.Pack) -> L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>:
  Entry.define(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body,world,name,pack)
def trace_result(~S:Data,state:State<S>) -> List<&2,Snapshot>:
  match state:
    case State{world,foreign,first,second,trace}:trace
def reregistered(~S:Data,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,status:Status,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> List<&2,Snapshot>:
  match result:
    case L.Registered{world,first}:trace_result(~S,run(~S,"returned-capture-run",Sys.Args{4,False{}},snapshot(~S,"reregistered",status,State{world,foreign,first,second,trace})))
    case L.RegistrationRejected{world,pack}:[]
def recovered(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,oldId:U32,valid:Bool,result:P.Pack & P.Observation) -> List<&2,Snapshot>:
  (pack,view) = result
  reregistered(~S,foreign,second,trace,Removed{view,oldId,valid},define(~S,world,"first",pack))
def removed_checked(~S:Data,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,oldId:U32,pack:P.Pack,result:W.World<S,Unit,U32,Unit> & Bool) -> List<&2,Snapshot>:
  (world,valid) = result
  recovered(~S,world,foreign,second,trace,oldId,valid,P.project(pack))
def removed(~S:Data,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,+oldId:U32,result:L.Disposal<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),P.Pack>) -> List<&2,Snapshot>:
  match result:
    case L.Disposed{world,pack}:removed_checked(~S,foreign,second,trace,oldId,pack,W.registration_matches(~S,~Unit,~U32,~Unit,world,oldId,"first",["Counter"]))
    case L.DisposalRejected{world,first}:trace_result(~S,snapshot(~S,"remove",Broken{"remove refused"},State{world,foreign,first,second,trace}))
def removal_id(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Snapshot>,result:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & U32) -> List<&2,Snapshot>:
  (first,id) = result
  removed(~S,foreign,second,trace,id,Capture.unregister(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first,world))
def remove(~S:Data,state:State<S>) -> List<&2,Snapshot>:
  match state:
    case State{world,foreign,first,second,trace}:removal_id(~S,world,foreign,second,trace,Capture.identity(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first))
# Both instances survive each observation; complete final owners are in last row.
def scenario(~S:Data,state:State<S>) -> List<&2,Snapshot>:
  state = snapshot(~S,"registered",Registered{},state)
  state = run(~S,"first",Sys.Args{1,False{}},state)
  state = swap(~S,run(~S,"second",Sys.Args{10,False{}},swap(~S,state)))
  state = skip(~S,state)
  state = run(~S,"failed",Sys.Args{2,True{}},state)
  state = run(~S,"retry",Sys.Args{3,False{}},state)
  state = foreign_run(~S,state)
  remove(~S,state)
def second_registered(~S:Data,foreign:W.World<S,Unit,U32,Unit>,first:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> List<&2,Snapshot>:
  match result:
    case L.Registered{world,second}:scenario(~S,State{world,foreign,first,second,[]})
    case _:[]
def first_registered(~S:Data,foreign:W.World<S,Unit,U32,Unit>,result:L.Registered<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> List<&2,Snapshot>:
  match result:
    case L.Registered{world,first}:second_registered(~S,foreign,first,define(~S,world,"second",P.initial(100)))
    case _:[]
def start(~S:Data,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>) -> List<&2,Snapshot>:
  first_registered(~S,foreign,define(~S,world,"first",P.initial(1)))
