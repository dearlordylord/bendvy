import Base
import schema-families.bend as D
import fixture.bend as Fixture
import execution.bend as Execution
import runtime-owners.bend as Owners
import world-observer.bend as Dump
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I

type Boundary is Data:
  Boundary{worldBefore:String,worldAfter:String,instanceBefore:String,instanceAfter:String}
type State<S:Data> is Type:
  State{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,Boundary>,errors:String}
type Step<S:Data> is Type:
  Step{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,Boundary>,errors:String}
def tasks() -> List<&2,Execution.QueryKind>:
  [Execution.KindEmpty{},Execution.KindOptionalFour{},Execution.KindRequiredPair{},Execution.KindFiveAlias{},Execution.KindWithWithout{},Execution.KindMultipleWith{},Execution.KindMultipleWithout{},Execution.KindRepeated{},Execution.KindContradictory{},Execution.KindAddedBoth{},Execution.KindChangedBoth{},Execution.KindMixedFilters{},Execution.KindRepeatedAdded{},Execution.KindOptionalUnselectedFilter{}]
def fresh(~S:Data,fuel:Nat) -> List<I.Instance<S>>:
  match fuel:
    case 0n:[]
    case 1n+rest:I.Fresh{} <> fresh(~S,rest)
def initial(~S:Data,fixture:Fixture.Fixture<S>) -> State<S>:
  match fixture:
    case Fixture.Fixture{world,targets,errors}:State{world,targets,fresh(~S,14n),[],[],errors}
def completed(~S:Data,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,Boundary>,errors:String,worldBefore:String,instanceBefore:String,record:String,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String,observedInstance:I.Instance<S> & String) -> Step<S>:
  (world,worldAfter)=observedWorld
  (instance,instanceAfter)=observedInstance
  Step{world,targets,remaining,instance <> finished,List.append(&2,String,records,[record]),List.append(&2,Boundary,boundaries,[Boundary{worldBefore,worldAfter,instanceBefore,instanceAfter}]),errors}
def observed(~S:Data,targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,Boundary>,errors:String,worldBefore:String,instanceBefore:String,value:I.Observed<S,D.Store<S>,Owners.Resource<S>,U32,Unit,String>) -> Step<S>:
  match value:
    case I.Observed{world,instance,Done{record}}:completed(~S,targets,remaining,finished,records,boundaries,errors,worldBefore,instanceBefore,record,Dump.world(~S,world),Dump.instance(~S,instance))
    case I.Observed{world,instance,Fail{_}}:completed(~S,targets,remaining,finished,records,boundaries,errors ++ "inspector-body-refused;",worldBefore,instanceBefore,"UNEXPECTED_INSPECTOR_REFUSAL",Dump.world(~S,world),Dump.instance(~S,instance))
def prepared(~S:Data,kind:Execution.QueryKind,+targets:List<&2,W.Handle<S>>,remaining:List<I.Instance<S>>,finished:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,Boundary>,errors:String,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String,observedInstance:I.Instance<S> & String) -> Step<S>:
  (world,before)=observedWorld
  (instance,position)=observedInstance
  observed(~S,targets,remaining,finished,records,boundaries,errors,before,position,Execution.run(~S,kind,world,instance,targets))
def next(~S:Data,kind:Execution.QueryKind,step:Step<S>) -> Step<S>:
  match step:
    case Step{world,targets,[],finished,records,boundaries,errors}:Step{world,targets,[],finished,records,boundaries,errors ++ "missing-query-instance;"}
    case Step{world,targets,instance <> remaining,finished,records,boundaries,errors}:prepared(~S,kind,targets,remaining,finished,records,boundaries,errors,Dump.world(~S,world),Dump.instance(~S,instance))
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
def workshop(state:State<D.Workshop>) -> State<D.Workshop>:
  run(~D.Workshop,state)
def garden(state:State<D.Garden>) -> State<D.Garden>:
  run(~D.Garden,state)
def main() -> Unit:
  Unit{}
