import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec

type State is Type:State{token:Array<U32>,invocations:U32}
def available(key:String) -> Bool:String.eq(key,"resource/present")
def condition(state:State,_:U32) -> State & Exec.Condition<String>:(state,Exec.Allowed{})
def dispatch(state:State,id:U32) -> State & Exec.Invocation<String,U32>:
  match state:
    case State{token,count}:(State{token,U32.add(count,1)},Exec.Completed{id})
def handler(state:State,_:String) -> State & Exec.Handling:(state,Exec.Continue{})
def reason(value:Plan.Invalid<String>) -> String:
  match value:
    case Plan.Duplicate{id}:"duplicate/" ++ U32.show(id)
    case Plan.UnknownDependency{id}:"unknown/" ++ U32.show(id)
    case Plan.Missing{id,requirement}:"missing/" ++ U32.show(id) ++ "/" ++ requirement
    case Plan.Cycle{}:"cycle"
    case Plan.InvalidCondition{id}:"writable-condition/" ++ U32.show(id)
def token(result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id)
def state(value:State) -> String:
  match value:
    case State{owned,count}:token(Array.get(U32,owned,0)) ++ "/" ++ U32.show(count)
def outcome(value:Exec.ExecutionResult<State,String,String,U32>) -> String:
  match value:
    case Exec.Invalid{owned,error}:reason(error) ++ "/owner=" ++ state(owned)
    case Exec.Finished{owned,_}:"finished/owner=" ++ state(owned)
    case Exec.Stopped{owned,_,_}:"stopped/owner=" ++ state(owned)
def check(nodes:List<&2,Plan.Node<String>>,edges:List<&2,Plan.Edge>) -> String:
  outcome(Exec.run(~State,~String,~String,~U32,~condition,~dispatch,~handler,Plan.build(~String,~available,nodes,edges),State{ALeaf{901},0}))
def ids(nodes:List<&2,Plan.Node<String>>) -> String:
  match nodes:
    case []:""
    case Plan.Node{id,_} <> rest:U32.show(id) ++ "," ++ ids(rest)
def sorted(value:Plan.Build<String>) -> String:
  match value:
    case Plan.Rejected{error}:reason(error)
    case Plan.Planned{nodes,_}:ids(nodes)
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(check([Plan.Node{3,[]},Plan.Node{3,[]}],[]))
    IO.print(check([Plan.Node{3,[]}],[Plan.Edge{3,4}]))
    IO.print(check([Plan.Node{4,["resource/missing"]}],[]))
    IO.print(check([Plan.Node{3,[]},Plan.Node{4,[]}],[Plan.Edge{3,4},Plan.Edge{4,3}]))
    IO.print(sorted(Plan.build(~String,~available,[Plan.Node{1,[]},Plan.Node{2,[]},Plan.Node{3,[]}],Plan.chain([2,1,3]))))
    IO.print(ids(Plan.ready(~String,[Plan.Node{1,[]},Plan.Node{2,[]},Plan.Node{3,[]}],[Plan.Edge{1,3}])))
