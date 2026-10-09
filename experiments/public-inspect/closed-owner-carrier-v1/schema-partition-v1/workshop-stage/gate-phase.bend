import Base
import schema-families.bend as D
import runtime-owners.bend as Owners
import gates.bend as G
import phase-driver.bend as P
import gate-instrumentation.bend as Instrument
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/schedule.bend as Sch

type Observation<S:Data> is Data:
  Observation{observations:List<&2,Sch.Observation>,argsBefore:String,argsAfter:String,diagnostic:Owners.Diagnostic<S>}
type State<S:Data> is Type:
  State{phase:P.State<S>,holders:List<G.Holder<S>>,gates:List<&2,Observation<S>>,errors:String}
type Step<S:Data> is Type:
  Step{world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,P.Boundary>,remaining:List<G.Holder<S>>,finished:List<G.Holder<S>>,gates:List<&2,Observation<S>>,errors:String}
def registered(~S:Data,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,P.Boundary>,errors:String,value:G.Registered<S>) -> State<S>:
  match value:
    case G.Registered{world,holders,error}:State{P.State{world,targets,instances,records,boundaries,errors},holders,[],error}
def initial(~S:Data,name:String,phase:P.State<S>) -> State<S>:
  match phase:
    case P.State{world,targets,instances,records,boundaries,errors}:registered(~S,targets,instances,records,boundaries,errors,G.register_all(~S,name,world))
def diagnostic(~S:Data,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,P.Boundary>,remaining:List<G.Holder<S>>,finished:List<G.Holder<S>>,gates:List<&2,Observation<S>>,errors:String,holder:G.Holder<S>,observations:List<&2,Sch.Observation>,before:String,after:String,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & Owners.Diagnostic<S>) -> Step<S>:
  (world,value)=observed
  Step{world,targets,instances,records,boundaries,remaining,holder <> finished,List.append(&2,Observation<S>,gates,[Observation{observations,before,after,value}]),errors}
def completed(~S:Data,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,String>,boundaries:List<&2,P.Boundary>,remaining:List<G.Holder<S>>,finished:List<G.Holder<S>>,gates:List<&2,Observation<S>>,errors:String,value:G.Gate<S>) -> Step<S>:
  match value:
    case G.Gate{world,holder,observations,before,after,error}:diagnostic(~S,targets,instances,records,boundaries,remaining,finished,gates,errors ++ error,holder,observations,before,after,W.observe_resource(~S,~D.Store<S>,~Owners.Resource<S>,~U32,~Owners.Diagnostic<S>,~Instrument.diagnostic(~S),world))
def next(~S:Data,+slot:U32,record:String,step:Step<S>) -> Step<S>:
  match step:
    case Step{world,targets,instances,records,boundaries,[],finished,gates,errors}:Step{world,targets,instances,records,boundaries,[],finished,gates,errors ++ "missing-gate-holder;"}
    case Step{world,+targets,instances,records,boundaries,holder <> remaining,finished,gates,errors}:completed(~S,targets,instances,records,boundaries,remaining,finished,gates,errors,G.run(~S,world,holder,slot,targets,record))
def finish(~S:Data,step:Step<S>) -> State<S>:
  match step:
    case Step{world,targets,instances,records,boundaries,remaining,finished,gates,errors}:State{P.State{world,targets,instances,records,boundaries,""},List.append(&1,G.Holder<S>,List.reverse(&1,G.Holder<S>,finished),remaining),gates,errors}
def scan(~S:Data,fuel:Nat,+slot:U32,records:List<&2,String>,step:Step<S>) -> State<S>:
  match fuel:
    case 0n:finish(~S,step)
    case 1n+rest:
      match records:
        case []:finish(~S,step)
        case record <> records:scan(~S,rest,(slot + 1 : U32),records,next(~S,slot,record,step))
def from_phase(~S:Data,holders:List<G.Holder<S>>,errors:String,phase:P.State<S>) -> State<S>:
  match phase:
    case P.State{world,+targets,instances,+records,boundaries,error}:scan(~S,9n,0,records,Step{world,targets,instances,records,boundaries,holders,[],[],errors ++ error})
def run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{phase,holders,_,errors}:from_phase(~S,holders,errors,P.run(~S,phase))
def workshop(state:State<D.Workshop>) -> State<D.Workshop>:
  run(~D.Workshop,state)
def main() -> Unit:
  Unit{}
