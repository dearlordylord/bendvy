import Base
import ../payload.bend as P
import ../system.bend as Sys
import ../scenario.bend as Old
import ../format.bend as F
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/captures.bend as Capture
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../../src/ecs/system.bend as System
import ../../../../src/ecs/schedule.bend as Sch

type Held<S:Data> is Type:
  Held{instance:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,args:Sys.Args}
type Error is Data:
  Failed{cause:Sys.Error}
  Refused{}
def dispatched(~S:Data,args:Sys.Args,result:L.Run<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>) -> Held<S> & System.Outcome<W.World<S,Unit,U32,Unit>,Error,Unit>:
  match result:
    case L.Completed{world,instance,Done{_}}:(Held{instance,args},System.Succeeded{world,Unit{}})
    case L.Completed{world,instance,Fail{error}}:(Held{instance,args},System.Failed{world,Failed{error}})
    case L.Refused{world,instance,actualArgs}:(Held{instance,actualArgs},System.Failed{world,Refused{}})
def dispatch(~S:Data,held:Held<S>,world:W.World<S,Unit,U32,Unit>,id:U32) -> Held<S> & System.Outcome<W.World<S,Unit,U32,Unit>,Error,Unit>:
  match held:
    case Held{instance,+args}:dispatched(~S,args,Capture.run(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),instance,world,args))
def condition(~S:Data,world:W.World<S,Unit,U32,Unit>,code:U32) -> W.World<S,Unit,U32,Unit> & Bool:
  (world,U32.is_eq(code,0))
def skipped(~S:Data,held:Held<S>,world:W.World<S,Unit,U32,Unit>,id:U32) -> Held<S> & W.World<S,Unit,U32,Unit>:
  match held:
    case Held{instance,args}:(Held{Capture.skip(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),instance),args},world)
def step(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def observations(values:List<&2,Sch.Observation>) -> String:
  List.show(~&2,~Sch.Observation,~step,values)
def planned(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
    case Sch.Phase{name}:"Phase:" ++ name
    case Sch.Barrier{}:"Barrier"
def plan_info(ns:U32,name:String,steps:List<&2,Sch.Step>,args:Sys.Args,obs:List<&2,Sch.Observation>) -> String:
  match args:
    case Sys.Args{delta,fail}:"plan=" ++ U32.show(ns) ++ ":" ++ name ++ ":" ++ List.show(~&2,~Sch.Step,~planned,steps) ++ ";args=" ++ U32.show(delta) ++ ":" ++ Bool.show(fail) ++ ";observations=" ++ observations(obs)
type Scheduled<S:Data> is Type:
  Scheduled{state:Old.State<S>,observations:String}
def returned(~S:Data,label:String,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Old.Snapshot>,result:Sch.RunResult<S,Unit,U32,Unit,Held<S>,Error>) -> Scheduled<S>:
  match result:
    case Sch.Finished{Sch.Schedule{ns,name,steps,Held{first,+args}},world,obs}:Scheduled{Old.snapshot(~S,label,Old.Success{},Old.State{world,foreign,first,second,trace}),plan_info(ns,name,steps,args,obs)}
    case Sch.Failed{Sch.Schedule{ns,name,steps,Held{first,+args}},world,Failed{error},obs}:Scheduled{Old.snapshot(~S,label,Old.Failure{error},Old.State{world,foreign,first,second,trace}),plan_info(ns,name,steps,args,obs)}
    case Sch.Failed{Sch.Schedule{ns,name,steps,Held{first,+args}},world,Refused{},obs}:Scheduled{Old.snapshot(~S,label,Old.Refused{args},Old.State{world,foreign,first,second,trace}),plan_info(ns,name,steps,args,obs)}
    case Sch.Rejected{Sch.Schedule{ns,name,steps,Held{first,+args}},world}:Scheduled{Old.snapshot(~S,label,Old.Broken{"schedule refused"},Old.State{world,foreign,first,second,trace}),plan_info(ns,name,steps,args,[])}
def built(~S:Data,label:String,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Old.Snapshot>,result:Sch.Build<S,Unit,U32,Unit,Held<S>>) -> Scheduled<S>:
  match result:
    case Sch.Built{schedule}:returned(~S,label,foreign,second,trace,Sch.run_with_skip(~S,~Unit,~U32,~Unit,~Held<S>,~Error,~skipped(~S),~dispatch(~S),~condition(~S),schedule,world))
    case Sch.Invalid{Held{first,args}}:Scheduled{Old.snapshot(~S,label,Old.Broken{"schedule invalid"},Old.State{world,foreign,first,second,trace}),"Invalid"}
def identified(~S:Data,label:String,world:W.World<S,Unit,U32,Unit>,foreign:W.World<S,Unit,U32,Unit>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Old.Snapshot>,ns:U32,code:U32,args:Sys.Args,result:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)> & U32) -> Scheduled<S>:
  (first,+id) = result
  built(~S,label,world,foreign,second,trace,Sch.build(~S,~Unit,~U32,~Unit,~Held<S>,ns,"capture",[Sch.Phase{"capture"},Sch.System{id,code},Sch.Barrier{}],[id],Held{first,args}))
def namespaced(~S:Data,label:String,foreign:W.World<S,Unit,U32,Unit>,first:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,second:L.Instance<S,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body)>,trace:List<&2,Old.Snapshot>,code:U32,args:Sys.Args,result:W.World<S,Unit,U32,Unit> & U32) -> Scheduled<S>:
  (world,ns) = result
  identified(~S,label,world,foreign,second,trace,ns,code,args,Capture.identity(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Ord.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~S),~Sys.body),first))
def run(~S:Data,label:String,code:U32,args:Sys.Args,state:Old.State<S>) -> Scheduled<S>:
  match state:
    case Old.State{world,foreign,first,second,trace}:namespaced(~S,label,foreign,first,second,trace,code,args,W.namespace(~S,~Unit,~U32,~Unit,world))
