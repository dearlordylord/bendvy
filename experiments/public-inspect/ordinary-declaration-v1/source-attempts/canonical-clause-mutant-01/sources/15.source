import Base
import schema-families.bend as D
import fixture.bend as Fixture
import mutations.bend as Mutation
import gate-phase.bend as GatePhase
import phase-driver.bend as Phase
import gates.bend as Gates
import runtime-owners.bend as Owners
import world-observer.bend as Dump
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/inspector.bend as I

type Record<S:Data> is Data:
  Record{name:String,queries:List<&2,String>,boundaries:List<&2,Phase.Boundary>,gates:List<&2,GatePhase.Observation<S>>,before:String,after:String,registriesBefore:List<&2,String>,registriesAfter:List<&2,String>}
type Driver<S:Data> is Type:
  Driver{state:GatePhase.State<S>,records:List<&2,Record<S>>}
def holders_join(~S:Data,head:Gates.Holder<S> & String,tail:List<Gates.Holder<S>> & List<&2,String>) -> List<Gates.Holder<S>> & List<&2,String>:
  (holder,a)=head
  (holders,b)=tail
  (holder <> holders,a <> b)
def holders(~S:Data,values:List<Gates.Holder<S>>) -> List<Gates.Holder<S>> & List<&2,String>:
  match values:
    case []:([],[])
    case value <> rest:holders_join(~S,Gates.holder(~S,value),holders(~S,rest))
def after(~S:Data,name:String,prior:List<&2,Record<S>>,before:String,registriesBefore:List<&2,String>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,+queries:List<&2,String>,+boundaries:List<&2,Phase.Boundary>,+gates:List<&2,GatePhase.Observation<S>>,errors:String,error:String,observed:List<Gates.Holder<S>> & List<&2,String>,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> Driver<S>:
  (current,registriesAfter)=observed
  (world,after)=observedWorld
  Driver{GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error},current,gates,errors},List.append(&2,Record<S>,prior,[Record{name,queries,boundaries,gates,before,after,registriesBefore,registriesAfter}])}
def completed(~S:Data,name:String,prior:List<&2,Record<S>>,before:String,registriesBefore:List<&2,String>,value:GatePhase.State<S>) -> Driver<S>:
  match value:
    case GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error},current,gates,errors}:after(~S,name,prior,before,registriesBefore,targets,instances,queries,boundaries,gates,errors,error,holders(~S,current),Dump.world(~S,world))
def prepared(~S:Data,name:String,prior:List<&2,Record<S>>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,queries:List<&2,String>,boundaries:List<&2,Phase.Boundary>,gates:List<&2,GatePhase.Observation<S>>,errors:String,error:String,observed:List<Gates.Holder<S>> & List<&2,String>,observedWorld:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> Driver<S>:
  (current,registriesBefore)=observed
  (world,before)=observedWorld
  completed(~S,name,prior,before,registriesBefore,GatePhase.run(~S,GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error},current,gates,errors}))
def phase(~S:Data,name:String,driver:Driver<S>) -> Driver<S>:
  match driver:
    case Driver{GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error},current,gates,errors},prior}:prepared(~S,name,prior,targets,instances,queries,boundaries,gates,errors,error,holders(~S,current),Dump.world(~S,world))
def mutated(~S:Data,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,queries:List<&2,String>,boundaries:List<&2,Phase.Boundary>,error:String,current:List<Gates.Holder<S>>,gates:List<&2,GatePhase.Observation<S>>,errors:String,prior:List<&2,Record<S>>,observed:W.World<S,D.Store<S>,Owners.Resource<S>,U32> & String) -> Driver<S>:
  (world,mutationError)=observed
  Driver{GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error ++ mutationError},current,gates,errors},prior}
def mutate_choice(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource<S>,U32>,+targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,queries:List<&2,String>,boundaries:List<&2,Phase.Boundary>,error:String,current:List<Gates.Holder<S>>,gates:List<&2,GatePhase.Observation<S>>,errors:String,prior:List<&2,Record<S>>,structural:Bool) -> Driver<S>:
  match structural:
    case False{}:mutated(~S,targets,instances,queries,boundaries,error,current,gates,errors,prior,Mutation.independent(~S,targets,world))
    case True{}:mutated(~S,targets,instances,queries,boundaries,error,current,gates,errors,prior,Mutation.structural(~S,targets,world))
def mutate(~S:Data,structural:Bool,driver:Driver<S>) -> Driver<S>:
  match driver:
    case Driver{GatePhase.State{Phase.State{world,targets,instances,queries,boundaries,error},current,gates,errors},prior}:mutate_choice(~S,world,targets,instances,queries,boundaries,error,current,gates,errors,prior,structural)
def all(~S:Data,state:GatePhase.State<S>) -> Driver<S>:
  phase(~S,"structuralMutations",mutate(~S,True{},phase(~S,"repeatAfterChanges",phase(~S,"independentLifecycle",mutate(~S,False{},phase(~S,"repeat",phase(~S,"bootstrap",Driver{state,[]})))))))
type Built<S:Data> is Type:
  Built{driver:Driver<S>}
  Refused{factory:W.Factory,resource:Owners.Resource<S>}
def built(~S:Data,name:String,value:Fixture.Built<S>) -> Built<S>:
  match value:
    case Fixture.Built{fixture}:Built{all(~S,GatePhase.initial(~S,name,Phase.initial(~S,fixture)))}
    case Fixture.BuildRefused{factory,resource}:Refused{factory,resource}
def workshop() -> Built<D.Workshop>:
  built(~D.Workshop,"Workshop",Fixture.workshop())
def garden() -> Built<D.Garden>:
  built(~D.Garden,"Garden",Fixture.garden())
def main() -> Unit:
  Unit{}
