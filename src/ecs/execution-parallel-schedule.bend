import Base
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

type Completed<Error:Data,Out:Data> is Data:
  Completed{id:U32,invocation:Exec.Invocation<Error,Out>}
type Filtered<State:Type,Requirement:Data,Error:Data,Out:Data> is Type:
  CandidatesReady{state:State,pending:List<&2,Plan.Node<Requirement>>,allowed:List<&2,U32>,events:List<&2,Exec.Observation<Error,Out>>}
  ConditionStopped{state:State,error:Error,events:List<&2,Exec.Observation<Error,Out>>}

def agrees(~Rules:Data,~compatible:Rules -> U32 -> U32 -> Bool,+rules:Rules,+id:U32,selected:List<&2,U32>) -> Bool:
  match selected:
    case []:True{}
    case other <> rest:Bool.and(compatible(rules,id,other),agrees(~Rules,~compatible,rules,id,rest))
def chosen(~Rules:Data,~Requirement:Data,~compatible:Rules -> U32 -> U32 -> Bool,continue:List<&2,U32> -> List<&2,U32>,allowed:Bool,id:U32,selected:List<&2,U32>) -> List<&2,U32>:
  match allowed:
    case True{}:continue(id <> selected)
    case False{}:continue(selected)
def select(~Rules:Data,~Requirement:Data,~compatible:Rules -> U32 -> U32 -> Bool,+rules:Rules,nodes:List<&2,Plan.Node<Requirement>>,+selected:List<&2,U32>) -> List<&2,U32>:
  match nodes:
    case []:List.reverse(&2,U32,selected)
    case Plan.Node{+id,_} <> rest:chosen(~Rules,~Requirement,~compatible,selected => select(~Rules,~Requirement,~compatible,rules,rest,selected),agrees(~Rules,~compatible,rules,id,selected),id,selected)
def remove_many(~Requirement:Data,ids:List<&2,U32>,nodes:List<&2,Plan.Node<Requirement>>) -> List<&2,Plan.Node<Requirement>>:
  match ids:
    case []:nodes
    case id <> rest:remove_many(~Requirement,rest,Plan.remove(~Requirement,nodes,id))

def condition_handled(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,U32> -> List<&2,Exec.Observation<Error,Out>> -> Filtered<State,Requirement,Error,Out>,returned:State & Exec.Handling,+error:Error,pending:List<&2,Plan.Node<Requirement>>,allowed:List<&2,U32>,events:List<&2,Exec.Observation<Error,Out>>) -> Filtered<State,Requirement,Error,Out>:
  match returned:
    case (state,Exec.Continue{}):next(state,pending,allowed,events)
    case (state,Exec.Escalate{}):ConditionStopped{state,error,events}
def conditioned(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,U32> -> List<&2,Exec.Observation<Error,Out>> -> Filtered<State,Requirement,Error,Out>,returned:State & Exec.Condition<Error>,+id:U32,pending:List<&2,Plan.Node<Requirement>>,allowed:List<&2,U32>,events:List<&2,Exec.Observation<Error,Out>>) -> Filtered<State,Requirement,Error,Out>:
  match returned:
    case (state,Exec.Allowed{}):next(state,pending,List.append(&2,U32,allowed,[id]),events)
    case (state,Exec.Disabled{}):next(state,Plan.remove(~Requirement,pending,id),allowed,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.Skipped{id}]))
    case (state,Exec.ConditionError{+error}):condition_handled(~Rules,~State,~Requirement,~Error,~Out,next,handler(state,error),error,Plan.remove(~Requirement,pending,id),allowed,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.ConditionFailed{id,error}]))
    case (state,Exec.ConditionRefused{}):next(state,Plan.remove(~Requirement,pending,id),allowed,List.append(&2,Exec.Observation<Error,Out>,events,[Exec.ConditionRejected{id}]))
def filter_conditions(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Exec.Condition<Error>,~handler:State -> Error -> State & Exec.Handling,selected:List<&2,U32>,pending:List<&2,Plan.Node<Requirement>>,allowed:List<&2,U32>,state:State,events:List<&2,Exec.Observation<Error,Out>>) -> Filtered<State,Requirement,Error,Out>:
  match selected:
    case []:CandidatesReady{state,pending,allowed,events}
    case +id <> rest:conditioned(~Rules,~State,~Requirement,~Error,~Out,~handler,state => pending => allowed => events => filter_conditions(~Rules,~State,~Requirement,~Error,~Out,~condition,~handler,rest,pending,allowed,state,events),condition(state,id),id,pending,allowed,events)

def completion_event(~Error:Data,~Out:Data,completion:Completed<Error,Out>) -> Exec.Observation<Error,Out>:
  match completion:
    case Completed{id,Exec.Completed{output}}:Exec.Ran{id,output}
    case Completed{id,Exec.BodyError{error,output}}:Exec.BodyFailed{id,error,output}
    case Completed{id,Exec.AdmissionRefused{}}:Exec.AdmissionRejected{id}
def collect_events(~Error:Data,~Out:Data,completions:List<&2,Completed<Error,Out>>) -> List<&2,Exec.Observation<Error,Out>>:
  match completions:
    case []:[]
    case first <> rest:completion_event(~Error,~Out,first) <> collect_events(~Error,~Out,rest)
def collect_error(~Error:Data,~Out:Data,completion:Completed<Error,Out>,rest:List<&2,Error>) -> List<&2,Error>:
  match completion:
    case Completed{_,Exec.BodyError{error,_}}:error <> rest
    case Completed{_,Exec.Completed{_}}:rest
    case Completed{_,Exec.AdmissionRefused{}}:rest
def collect_errors(~Error:Data,~Out:Data,completions:List<&2,Completed<Error,Out>>) -> List<&2,Error>:
  match completions:
    case []:[]
    case first <> rest:collect_error(~Error,~Out,first,collect_errors(~Error,~Out,rest))

def body_handled(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:State & Exec.Handling,error:Error,pending:List<&2,Plan.Node<Requirement>>,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,Exec.Continue{}):next(state,pending,events)
    case (state,Exec.Escalate{}):Exec.Stopped{state,error,events}
def handle_errors(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,errors:List<&2,Error>,state:State,pending:List<&2,Plan.Node<Requirement>>,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match errors:
    case []:next(state,pending,events)
    case +error <> rest:body_handled(~Rules,~State,~Requirement,~Error,~Out,state => pending => events => handle_errors(~Rules,~State,~Requirement,~Error,~Out,~handler,next,rest,state,pending,events),handler(state,error),error,pending,events)
def dispatched(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,pending:List<&2,Plan.Node<Requirement>>,selected:List<&2,U32>,events:List<&2,Exec.Observation<Error,Out>>,returned:State & List<&2,Completed<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,+completions):handle_errors(~Rules,~State,~Requirement,~Error,~Out,~handler,next,collect_errors(~Error,~Out,completions),state,remove_many(~Requirement,selected,pending),List.append(&2,Exec.Observation<Error,Out>,events,collect_events(~Error,~Out,completions)))
def allowed_selected(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,+allowed:List<&2,U32>,state:State,pending:List<&2,Plan.Node<Requirement>>,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match allowed:
    case []:next(state,pending,events)
    case _ <> _:dispatched(~Rules,~State,~Requirement,~Error,~Out,~handler,next,pending,allowed,events,groupDispatch(state,allowed))
def filtered(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:Filtered<State,Requirement,Error,Out>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case ConditionStopped{state,error,events}:Exec.Stopped{state,error,events}
    case CandidatesReady{state,pending,allowed,events}:allowed_selected(~Rules,~State,~Requirement,~Error,~Out,~groupDispatch,~handler,next,allowed,state,pending,events)
def selected(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Exec.Condition<Error>,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,ids:List<&2,U32>,state:State,pending:List<&2,Plan.Node<Requirement>>,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match ids:
    case []:Exec.Invalid{state,Plan.Cycle{}}
    case _ <> _:filtered(~Rules,~State,~Requirement,~Error,~Out,~groupDispatch,~handler,next,filter_conditions(~Rules,~State,~Requirement,~Error,~Out,~condition,~handler,ids,pending,[],state,events))
def step(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Exec.Condition<Error>,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,~compatible:Rules -> U32 -> U32 -> Bool,~ready:List<&2,Plan.Node<Requirement>> -> List<&2,Plan.Edge> -> List<&2,Plan.Node<Requirement>>,next:State -> List<&2,Plan.Node<Requirement>> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,+rules:Rules,+pending:List<&2,Plan.Node<Requirement>>,edges:List<&2,Plan.Edge>,state:State,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match pending:
    case []:Exec.Finished{state,events}
    case _ <> _:selected(~Rules,~State,~Requirement,~Error,~Out,~condition,~groupDispatch,~handler,next,select(~Rules,~Requirement,~compatible,rules,ready(pending,edges),[]),state,pending,events)
def exhausted(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,pending:List<&2,Plan.Node<Requirement>>,state:State,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match pending:
    case []:Exec.Finished{state,events}
    case _ <> _:Exec.Invalid{state,Plan.Cycle{}}
def execute(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Exec.Condition<Error>,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,~compatible:Rules -> U32 -> U32 -> Bool,~ready:List<&2,Plan.Node<Requirement>> -> List<&2,Plan.Edge> -> List<&2,Plan.Node<Requirement>>,fuel:Nat,+rules:Rules,pending:List<&2,Plan.Node<Requirement>>,+edges:List<&2,Plan.Edge>,state:State,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match fuel:
    case 0n:exhausted(~Rules,~State,~Requirement,~Error,~Out,pending,state,events)
    case 1n++rest:step(~Rules,~State,~Requirement,~Error,~Out,~condition,~groupDispatch,~handler,~compatible,~ready,state => pending => events => execute(~Rules,~State,~Requirement,~Error,~Out,~condition,~groupDispatch,~handler,~compatible,~ready,rest,rules,pending,edges,state,events),rules,pending,edges,state,events)
def run(~Rules:Data,~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Exec.Condition<Error>,~groupDispatch:State -> List<&2,U32> -> State & List<&2,Completed<Error,Out>>,~handler:State -> Error -> State & Exec.Handling,~compatible:Rules -> U32 -> U32 -> Bool,~ready:List<&2,Plan.Node<Requirement>> -> List<&2,Plan.Edge> -> List<&2,Plan.Node<Requirement>>,rules:Rules,plan:Plan.Build<Requirement>,state:State) -> Exec.ExecutionResult<State,Requirement,Error,Out>:
  match plan:
    case Plan.Rejected{reason}:Exec.Invalid{state,reason}
    case Plan.Planned{+nodes,edges}:execute(~Rules,~State,~Requirement,~Error,~Out,~condition,~groupDispatch,~handler,~compatible,~ready,List.length(&2,Plan.Node<Requirement>,nodes),rules,nodes,edges,state,[])
