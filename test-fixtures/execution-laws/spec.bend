import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec

def after_handler(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:State & Exec.Handling,error:Error,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,Exec.Continue{}):next(state,events)
    case (state,Exec.Escalate{}):Exec.Stopped{state,error,events}

def includes(~Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+id:U32) -> Bool:
  match nodes:
    case []:False{}
    case Plan.Node{other,_} <> rest:Bool.or(U32.is_eq(other,id),includes(~Requirement,rest,id))

def dependency_satisfied(~Requirement:Data,+pending:List<&2,Plan.Node<Requirement>>,+id:U32,edge:Plan.Edge) -> Bool:
  match edge:
    case Plan.Edge{before,after}:Bool.or(Bool.not(U32.is_eq(after,id)),Bool.not(includes(~Requirement,pending,before)))

def all_dependencies_satisfied(~Requirement:Data,+pending:List<&2,Plan.Node<Requirement>>,+id:U32,edges:List<&2,Plan.Edge>) -> Bool:
  match edges:
    case []:True{}
    case edge <> rest:Bool.and(dependency_satisfied(~Requirement,pending,id,edge),all_dependencies_satisfied(~Requirement,pending,id,rest))

def include_ready(~Requirement:Data,ready:Bool,node:Plan.Node<Requirement>,rest:List<&2,Plan.Node<Requirement>>) -> List<&2,Plan.Node<Requirement>>:
  match ready:
    case False{}:rest
    case True{}:node <> rest

def scan_ready(~Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+pending:List<&2,Plan.Node<Requirement>>,+edges:List<&2,Plan.Edge>) -> List<&2,Plan.Node<Requirement>>:
  match nodes:
    case []:[]
    case Plan.Node{+id,+needs} <> rest:include_ready(~Requirement,all_dependencies_satisfied(~Requirement,pending,id,edges),Plan.Node{id,needs},scan_ready(~Requirement,rest,pending,edges))

def ready(~Requirement:Data,+pending:List<&2,Plan.Node<Requirement>>,edges:List<&2,Plan.Edge>) -> List<&2,Plan.Node<Requirement>>:
  scan_ready(~Requirement,pending,pending,edges)
