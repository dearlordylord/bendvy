import Base
import ledger-driver.bend as L
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/types.bend as T
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/stateful-driver.bend as D
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/stepper.bend as Stepper
import ../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/observe.bend as O

def kind(step:Stepper.Step) -> String:
  match step:
    case Stepper.Queue{_,_}: "queue"
    case Stepper.Marker{}: "marker"
    case Stepper.Read{}: "read"
def sample(sample:L.Sample) -> String:
  match sample:
    case L.SetupSample{_,_}: O.quote("setup")
    case L.StepSample{D.Operation{step,_},_,_}: O.quote(kind(step))
def scenario(~S:Data,result:L.ScenarioResult<S>) -> String:
  match result:
    case L.Completed{_,rows,samples,captures}:
      "{\"rows\":" ++ List.show(&2,String,s => s,rows) ++ ",\"sampleKinds\":" ++ List.show(&2,L.Sample,s => sample(s),samples) ++ ",\"captures\":" ++ List.show(&2,String,s => s,captures) ++ "}"
    case L.ConstructionRefused{_,_,_}: "{\"error\":\"ConstructionRefused\"}"
def scenarios(~S:Data,items:List<&1,L.ScenarioResult<S>>) -> List<&2,String>:
  match items:
    case []: []
    case result <> rest: scenario(~S,result) <> scenarios(~S,rest)
def rendered(~S:Data,ledger:L.Ledger<S>) -> String:
  match ledger:
    case L.Ledger{items}: List.show(&2,String,s => s,scenarios(~S,items))
def print_B(text:String,result:L.Ledger<T.SchemaB>) -> IO(Unit):
  IO.print("{\"A\":" ++ text ++ ",\"B\":" ++ rendered(~T.SchemaB,result) ++ "}")
def print_A(result:L.Ledger<T.SchemaA>) -> IO(Unit):
  IO.bind(L.Ledger<T.SchemaB>,Unit,L.run(~T.SchemaB,L.Correctness{},1n),b => print_B(rendered(~T.SchemaA,result),b))
def main() -> IO(Unit):
  IO.bind(L.Ledger<T.SchemaA>,Unit,L.run(~T.SchemaA,L.Correctness{},1n),a => print_A(a))

# 1n is the finite correctness fixture cardinality, not a timing population.
# Correctness mode uses IO.pure timestamps: this entrypoint never requests IO.now.
# Actual final scenario owners are disposed only by rendering after all operations.
