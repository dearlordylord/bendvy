import Base
import ./pooled-constructors.bend as Pool
import ./pooled-restore.bend as Preparation
import ./extended-flow.bend as Flow
import ./extended-execution.bend as Execution
import ./extended-resume.bend as Resume
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-save.bend as Save
import ./extended-main.bend as Observe
import ./observation.bend as BasicObserve
import ./declarations.bend as O
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/restore-leaf.bend as Leaf
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/decode-construction.bend as Constructor
import ../../src/ecs/entity-key-render.bend as Key

type Outcome<-S:Data> is Type:
  SourceRefused{result:Flow.Outcome<S>}
  DefinitionRefused{source:Resume.Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>}
  Prepared{source:Resume.Source<S>,result:Preparation.Outcome<S>}
  SaveRefused{source:Resume.Source<S>,state:Pool.State(~S),error:R.Error<Pool.Error>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),result:Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>}
  Retried{state:Pool.State(~S),error:R.Error<Pool.Error>,refused:Extended.Snapshot<S>,result:Resume.Outcome<S>}
def resumed(~S:Data,state:Pool.State(~S),error:R.Error<Pool.Error>,refused:Extended.Snapshot<S>,result:Resume.Outcome<S>) -> Outcome<S>:Retried{state,error,refused,result}
# The caller retains the recovered pool state outside this retry and chooses the
# ordinary allocating constructor. Its recovered buffer stays owned by Retried.
def saved(~S:Data,native:Bool,source:Resume.Source<S>,state:Pool.State(~S),error:R.Error<Pool.Error>,input:Extended.Snapshot<S>,held:Execution.Held<S>,result:Admission.Recipes(~S) & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(world,Gate.Saved{refused})):IO.bind(Resume.Outcome<S>,Outcome<S>,Resume.restored(~S,native,source,Execution.restore(~S,schema,input,Execution.rejoin(~S,held,world))),result => IO.pure(Outcome<S>,resumed(~S,state,error,refused,result)))
    case (schema,(world,result)):IO.pure(Outcome<S>,SaveRefused{source,state,error,schema,input,Execution.rejoin(~S,held,world),result})
def prepared(~S:Data,native:Bool,source:Resume.Source<S>,result:Preparation.Outcome<S>) -> IO(Outcome<S>):
  match result:
    case Preparation.ConstructorRefused{schema,input,Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred},state,error}:saved(~S,native,source,state,error,input,Execution.Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred},Save.save(~S,schema,world))
    case result:IO.pure(Outcome<S>,Prepared{source,result})
def defined(~S:Data,native:Bool,source:Resume.Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Execution.Defined{app}:prepared(~S,native,source,Preparation.prepare(~S,schema,input,app,[ALeaf{5151}]))
    case result:IO.pure(Outcome<S>,DefinitionRefused{source,schema,input,result})
def source(~S:Data,native:Bool,result:Flow.Outcome<S>) -> IO(Outcome<S>):
  match result:
    case Flow.Prepared{source,previous,reader,receipt,schema,input,target}:defined(~S,native,Resume.Source{source,previous,receipt},schema,input,Execution.setup(~S,target,reader))
    case result:IO.pure(Outcome<S>,SourceRefused{result})
def run(~S:Data,native:Bool) -> IO(Outcome<S>):IO.bind(Flow.Outcome<S>,Outcome<S>,Flow.prepare(~S),result => source(~S,native,result))
def buffer(value:Array<U32>) -> String:
  match value:
    case ALeaf{value}:U32.show(value)
    case ANode{left,right}:"[" ++ buffer(left) ++ "," ++ buffer(right) ++ "]"
def incoming(value:Pool.Input) -> String:
  match value:
    case Pool.Input{raw,None{}}:BasicObserve.raw(raw) ++ "/buffer=none"
    case Pool.Input{raw,Some{values}}:BasicObserve.raw(raw) ++ "/buffer=" ++ buffer(values)
def actor(~S:Data,value:O.Actor<S>) -> String:
  match value:
    case O.Actor{name,values}:name ++ "/" ++ buffer(values)
def record(~S:Data,value:Leaf.Record<Pool.Input,O.Actor<S>>) -> String:
  match value:
    case Leaf.Record{_,owner,_}:actor(~S,owner)
def recovered(~S:Data,state:Pool.State(~S)) -> String:
  match state:
    case Leaf.State{Pool.Context{_,available},records,returned,removed,applied}:"available=" ++ List.show(&1,Array<U32>,buffer,available) ++ "/records=" ++ List.show(&1,Leaf.Record<Pool.Input,O.Actor<S>>,record(~S),records) ++ "/returned=" ++ List.show(&1,Pool.Input,incoming,returned) ++ "/removed=" ++ List.show(&1,O.Actor<S>,actor(~S),removed) ++ "/applied=" ++ Nat.show(List.length(&1,Leaf.Applied<Pool.Input,O.Actor<S>>,applied))
def error(value:R.Error<Pool.Error>) -> String:
  match value:
    case R.InvalidComponent{saved,name,Constructor.Constructor{Pool.NoBuffer{}}}:"pool-exhausted/" ++ Key.show(saved) ++ "/" ++ name
    case _:"other-refusal"
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Retried{state,reason,refused,result}:error(reason) ++ "/recovery=" ++ recovered(~S,state) ++ "/actualReceiver=" ++ Observe.snapshot(~S,refused) ++ "/retry=" ++ Resume.observed(~S,result)
    case SourceRefused{_}:"source-refused"
    case DefinitionRefused{_,_,_,_}:"definition-refused"
    case Prepared{_,_}:"preparation-returned"
    case SaveRefused{_,_,_,_,_,_,_}:"save-refused"
def main() -> IO(Unit):IO.bind(Outcome<O.Alpha>,Unit,run(~O.Alpha,False{}),a => IO.bind(Unit,Unit,IO.print("alpha-serial " ++ observed(~O.Alpha,a)),u => IO.bind(Outcome<O.Beta>,Unit,run(~O.Beta,True{}),b => IO.print("beta-native " ++ observed(~O.Beta,b)))))
