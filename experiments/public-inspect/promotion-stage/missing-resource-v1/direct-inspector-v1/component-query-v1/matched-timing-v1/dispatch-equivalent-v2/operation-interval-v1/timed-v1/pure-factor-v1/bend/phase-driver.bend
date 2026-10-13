import Base
import schema-families.bend as D
import fixture.bend as Fixture
import execution.bend as Execution
import runtime-owners.bend as Owners
import world-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

type InstanceView is Data:
  FreshView{}
  ActiveView{cursor:U32,registeredAt:U32}
def instance_view(~S:Data,value:I.Instance<S>) -> I.Instance<S> & InstanceView:
  match value:
    case I.Fresh{}:(I.Fresh{},FreshView{})
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},ActiveView{cursor,registeredAt})
def instance_text(value:InstanceView) -> String:
  match value:
    case FreshView{}:"Fresh"
    case ActiveView{cursor,registeredAt}:"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt)
type Boundary is Data:
  Boundary{worldBefore:U32,worldAfter:U32,instanceBefore:InstanceView,instanceAfter:InstanceView}
type State<S:Data> is Type:
  State{world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,Execution.Record<S>>,boundaries:List<&2,Boundary>,errors:String}
type Step<S:Data> is Type:
  Step{world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,Execution.Record<S>>,boundaries:List<&2,Boundary>,errors:String}
def tasks() -> List<&2,Execution.QueryKind>:
  [Execution.KindEmpty{},Execution.KindOptionalFour{},Execution.KindRequiredPair{},Execution.KindFiveAlias{},Execution.KindWithWithout{},Execution.KindMultipleWith{},Execution.KindMultipleWithout{},Execution.KindRepeated{},Execution.KindContradictory{},Execution.KindAddedBoth{},Execution.KindChangedBoth{},Execution.KindMixedFilters{},Execution.KindRepeatedAdded{},Execution.KindOptionalUnselectedFilter{}]
def fresh(~S:Data,fuel:Nat) -> List<I.Instance<S>>:
  match fuel:
    case 0n:[]
    case 1n+rest:I.Fresh{} <> fresh(~S,rest)
def initial(~S:Data,fixture:Fixture.Fixture<S>) -> State<S>:
  match fixture:
    case Fixture.Fixture{world,targets,errors}:State{world,targets,fresh(~S,14n),[],[],errors}
def clock_text(~S:Data,result:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32) -> W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32:
  (world,clock)=result
  (world,clock)
def clock(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>) -> W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32:
  clock_text(~S,W.clock(~S,~D.Store<S>,~Owners.Resource(~S),~U32,world))
def completed(~S:Data,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,Execution.Record<S>>,boundaries:List<&2,Boundary>,errors:String,worldBefore:U32,instanceBefore:InstanceView,record:Execution.Record<S>,observedWorld:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32,observedInstance:I.Instance<S> & InstanceView) -> Step<S>:
  (world,worldAfter)=observedWorld
  (instance,instanceAfter)=observedInstance
  Step{world,targets,remaining,instance <> finished,List.append(&2,Execution.Record<S>,records,[record]),List.append(&2,Boundary,boundaries,[Boundary{worldBefore,worldAfter,instanceBefore,instanceAfter}]),errors}
def observed(~S:Data,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,Execution.Record<S>>,boundaries:List<&2,Boundary>,errors:String,worldBefore:U32,instanceBefore:InstanceView,value:I.Observed<S,D.Store<S>,Owners.Resource(~S),U32,Unit,Execution.Record<S>>) -> Step<S>:
  match value:
    case I.Observed{world,instance,Done{record}}:completed(~S,targets,remaining,finished,records,boundaries,errors,worldBefore,instanceBefore,record,clock(~S,world),instance_view(~S,instance))
    case I.Observed{world,instance,Fail{_}}:completed(~S,targets,remaining,finished,records,boundaries,errors ++ "inspector-body-refused;",worldBefore,instanceBefore,Execution.ErrorRecord{"UNEXPECTED_INSPECTOR_REFUSAL"},clock(~S,world),instance_view(~S,instance))
def prepared(~S:Data,kind:Execution.QueryKind,+targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,Execution.Record<S>>,boundaries:List<&2,Boundary>,errors:String,observedWorld:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & U32,observedInstance:I.Instance<S> & InstanceView) -> Step<S>:
  (world,before)=observedWorld
  (instance,position)=observedInstance
  observed(~S,targets,remaining,finished,records,boundaries,errors,before,position,Execution.run(~S,kind,world,instance,targets))
def next(~S:Data,kind:Execution.QueryKind,step:Step<S>) -> Step<S>:
  match step:
    case Step{world,targets,[],finished,records,boundaries,errors}:Step{world,targets,[],finished,records,boundaries,errors ++ "missing-query-instance;"}
    case Step{world,targets,instance <> remaining,finished,records,boundaries,errors}:prepared(~S,kind,targets,remaining,finished,records,boundaries,errors,clock(~S,world),instance_view(~S,instance))
def finish(~S:Data,step:Step<S>) -> State<S>:
  match step:
    case Step{world,targets,remaining,finished,records,boundaries,errors}:State{world,targets,List.append(&1,I.Instance<S>,List.reverse(&1,I.Instance<S>,finished),remaining),records,boundaries,errors}
def scan(~S:Data,tasks:List<&2,Execution.QueryKind>,step:Step<S>) -> State<S>:
  match tasks:
    case []:finish(~S,step)
    case kind <> rest:scan(~S,rest,next(~S,kind,step))
def run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,targets,instances,_,_,errors}:scan(~S,tasks(),Step{world,targets,instances,[],[],[],errors})
