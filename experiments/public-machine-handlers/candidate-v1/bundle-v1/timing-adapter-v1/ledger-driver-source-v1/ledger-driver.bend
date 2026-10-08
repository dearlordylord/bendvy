import Base
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/types.bend as T
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/batch.bend as B
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/clock-step.bend as C
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/stateful-driver.bend as D
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/observe.bend as O

type Mode is Data:
  Correctness{}
  Clocked{}
def now(mode:Mode) -> IO(Nat):
  match mode:
    case Correctness{}: IO.pure(Nat,0n)
    case Clocked{}: IO.now()
def timed(~S:Data,mode:Mode,batch:B.Batch<S>,step:D.Operation) -> IO(C.Timed<S>):
  match mode step:
    case Correctness{}, D.Operation{operation,_}: IO.pure(C.Timed<S>,C.Timed{B.step(~S,batch,operation),0n,0n})
    case Clocked{}, D.Operation{operation,_}: C.step(~S,batch,operation)

type Sample is Data:
  SetupSample{started:Nat,finished:Nat}
  StepSample{operation:D.Operation,started:Nat,finished:Nat}
type ScenarioResult<S:Data> is Type:
  Completed{batch:B.Batch<S>,rows:List<&2,String>,samples:List<&2,Sample>}
  ConstructionRefused{batch:B.Batch<S>,started:Nat,finished:Nat}
type Ledger<S:Data> is Type:
  Ledger{scenarios:List<&1,ScenarioResult<S>>}

def row(name:String,values:List<&2,String>) -> String:
  "{\"name\":" ++ O.quote(name) ++ ",\"values\":" ++ List.show(&2,String,s => s,values) ++ "}"
def captured(~S:Data,name:String,rows:List<&2,String>,samples:List<&2,Sample>,result:B.Observation<S>) -> ScenarioResult<S>:
  match result:
    case B.Observed{batch,values}: Completed{batch,List.append(&2,String,rows,[row(name,values)]),samples}
def checkpoint(~S:Data,batch:B.Batch<S>,rows:List<&2,String>,samples:List<&2,Sample>,name:Maybe<&2,String>) -> ScenarioResult<S>:
  match name:
    case None{}: Completed{batch,rows,samples}
    case Some{name}: captured(~S,name,rows,samples,B.observe(~S,batch))
def operation_returned(~S:Data,result:C.Timed<S>,rows:List<&2,String>,samples:List<&2,Sample>,operation:D.Operation,next:ScenarioResult<S> -> IO(ScenarioResult<S>)) -> IO(ScenarioResult<S>):
  match result operation:
    case C.Timed{batch,started,finished}, D.Operation{step,+name}:
      next(checkpoint(~S,batch,rows,List.append(&2,Sample,samples,[StepSample{D.Operation{step,name},started,finished}]),name))
def operations(~S:Data,+mode:Mode,items:List<&2,D.Operation>,result:ScenarioResult<S>) -> IO(ScenarioResult<S>):
  match items result:
    case [], result: IO.pure(ScenarioResult<S>,result)
    case _, ConstructionRefused{batch,started,finished}: IO.pure(ScenarioResult<S>,ConstructionRefused{batch,started,finished})
    case D.Operation{+step,+name} <> remaining, Completed{batch,rows,samples}:
      IO.bind(C.Timed<S>,ScenarioResult<S>,timed(~S,mode,batch,D.Operation{step,name}),returned =>
        operation_returned(~S,returned,rows,samples,D.Operation{step,name},next => operations(~S,mode,remaining,next)))
def setup_stopped(~S:Data,mode:Mode,items:List<&2,D.Operation>,batch:B.Batch<S>,started:Nat,finished:Nat) -> IO(ScenarioResult<S>):
  operations(~S,mode,items,Completed{batch,[],[SetupSample{started,finished}]})
def setup_returned(~S:Data,+mode:Mode,items:List<&2,D.Operation>,started:Nat,result:B.Setup<S>) -> IO(ScenarioResult<S>):
  match result:
    case B.Ready{_,batch}:
      IO.bind(Nat,ScenarioResult<S>,now(mode),finished => setup_stopped(~S,mode,items,batch,started,finished))
    case B.Refused{_,batch}:
      IO.bind(Nat,ScenarioResult<S>,now(mode),finished => IO.pure(ScenarioResult<S>,ConstructionRefused{batch,started,finished}))
def scenario(~S:Data,+mode:Mode,count:Nat,descriptor:D.Scenario) -> IO(ScenarioResult<S>):
  match descriptor:
    case D.Scenario{current,extra,failure,items}:
      IO.bind(Nat,ScenarioResult<S>,now(mode),started => setup_returned(~S,mode,items,started,B.setup(~S,count,current,extra,failure)))
def scenarios(~S:Data,+mode:Mode,+count:Nat,items:List<&2,D.Scenario>,completed:List<&1,ScenarioResult<S>>) -> IO(Ledger<S>):
  match items:
    case []: IO.pure(Ledger<S>,Ledger{completed})
    case descriptor <> remaining:
      IO.bind(ScenarioResult<S>,Ledger<S>,scenario(~S,mode,count,descriptor),result => scenarios(~S,mode,count,remaining,List.append(&1,ScenarioResult<S>,completed,[result])))
def run(~S:Data,mode:Mode,count:Nat) -> IO(Ledger<S>):
  scenarios(~S,mode,count,D.scenarios(),[])

# Source proposal only: no count is chosen and no entrypoint invokes clocks.
# Samples carry exact start/end without ratios. All final owners remain in Ledger.
# B.observe is called only after C.step has returned both clocks and owners.
# Each checkpoint preserves every population member, in batch author order.
