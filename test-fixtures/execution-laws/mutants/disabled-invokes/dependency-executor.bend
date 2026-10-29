import Base
import ../../../../src/ecs/dependency-plan.bend as Plan

type Condition<Error:Data> is Data:
  Allowed{}
  Disabled{}
  ConditionError{error:Error}
  ConditionRefused{}
type Invocation<Error:Data,Out:Data> is Data:
  Completed{output:Out}
  BodyError{error:Error,output:Out}
  AdmissionRefused{}
type Handling is Data:
  Continue{}
  Escalate{}
type Observation<Error:Data,Out:Data> is Data:
  Ran{id:U32,output:Out}
  BodyFailed{id:U32,error:Error,output:Out}
  Skipped{id:U32}
  ConditionFailed{id:U32,error:Error}
  ConditionRejected{id:U32}
  AdmissionRejected{id:U32}
type ExecutionResult<State:Type,Requirement:Data,Error:Data,Out:Data> is Type:
  Finished{state:State,events:List<&2,Observation<Error,Out>>}
  Stopped{state:State,error:Error,events:List<&2,Observation<Error,Out>>}
  Invalid{state:State,reason:Plan.Invalid<Requirement>}

def handled(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,next:State -> List<&2,Observation<Error,Out>> -> ExecutionResult<State,Requirement,Error,Out>,returned:State & Handling,error:Error,events:List<&2,Observation<Error,Out>>) -> ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,Continue{}):next(state,events)
    case (state,Escalate{}):Stopped{state,error,events}

def invoked(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~handler:State -> Error -> State & Handling,next:State -> List<&2,Observation<Error,Out>> -> ExecutionResult<State,Requirement,Error,Out>,returned:State & Invocation<Error,Out>,+id:U32,events:List<&2,Observation<Error,Out>>) -> ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,Completed{output}):next(state,List.append(&2,Observation<Error,Out>,events,[Ran{id,output}]))
    case (state,BodyError{+error,output}):handled(~State,~Requirement,~Error,~Out,next,handler(state,error),error,List.append(&2,Observation<Error,Out>,events,[BodyFailed{id,error,output}]))
    case (state,AdmissionRefused{}):next(state,List.append(&2,Observation<Error,Out>,events,[AdmissionRejected{id}]))

def conditioned(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~dispatch:State -> U32 -> State & Invocation<Error,Out>,~handler:State -> Error -> State & Handling,next:State -> List<&2,Observation<Error,Out>> -> ExecutionResult<State,Requirement,Error,Out>,returned:State & Condition<Error>,+id:U32,events:List<&2,Observation<Error,Out>>) -> ExecutionResult<State,Requirement,Error,Out>:
  match returned:
    case (state,Allowed{}):invoked(~State,~Requirement,~Error,~Out,~handler,next,dispatch(state,id),id,events)
    case (state,Disabled{}):invoked(~State,~Requirement,~Error,~Out,~handler,next,dispatch(state,id),id,events)
    case (state,ConditionError{+error}):handled(~State,~Requirement,~Error,~Out,next,handler(state,error),error,List.append(&2,Observation<Error,Out>,events,[ConditionFailed{id,error}]))
    case (state,ConditionRefused{}):next(state,List.append(&2,Observation<Error,Out>,events,[ConditionRejected{id}]))

def execute(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Condition<Error>,~dispatch:State -> U32 -> State & Invocation<Error,Out>,~handler:State -> Error -> State & Handling,order:List<&2,Plan.Node<Requirement>>,state:State,events:List<&2,Observation<Error,Out>>) -> ExecutionResult<State,Requirement,Error,Out>:
  match order:
    case []:Finished{state,events}
    case Plan.Node{+id,_} <> rest:conditioned(~State,~Requirement,~Error,~Out,~dispatch,~handler,state => events => execute(~State,~Requirement,~Error,~Out,~condition,~dispatch,~handler,rest,state,events),condition(state,id),id,events)

# State contains the actual World, registration, argument, condition and handler
# owners. Closed providers move that state and never duplicate runtime callbacks.
# The ordered interpreter chooses one valid order; parallel execution may choose
# any order permitted by dependencies and access conflicts.
def run(~State:Type,~Requirement:Data,~Error:Data,~Out:Data,~condition:State -> U32 -> State & Condition<Error>,~dispatch:State -> U32 -> State & Invocation<Error,Out>,~handler:State -> Error -> State & Handling,plan:Plan.Build<Requirement>,state:State) -> ExecutionResult<State,Requirement,Error,Out>:
  match plan:
    case Plan.Rejected{reason}:Invalid{state,reason}
    case Plan.Planned{order,_}:execute(~State,~Requirement,~Error,~Out,~condition,~dispatch,~handler,order,state,[])
