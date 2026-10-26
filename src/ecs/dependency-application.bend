import Base
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./dependency-registration.bend as Reg

type Binding is Data:Binding{system:U32,condition:U32}
type State<World:Type,Owners:Type,Guards:Type,Handler:Type> is Type:
  State{world:World,owners:Owners,guards:Guards,handler:Handler,bindings:List<&2,Binding>}
type Application<-World:Type,-Owners:Type,-Guards:Type,-Handler:Type,-Error:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),-guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),-handle:Handler -> Error -> Handler & Exec.Handling> is Type:
  Application{state:State<World,Owners,Guards,Handler>,plan:Plan.Build<String>,bindings:List<&2,Binding>}
type Report<Error:Data,Out:Data> is Data:
  Finished{events:List<&2,Exec.Observation<Error,Out>>}
  Stopped{error:Error,events:List<&2,Exec.Observation<Error,Out>>}
  Invalid{reason:Plan.Invalid<String>}

def binding_selected(selected:Bool,condition:U32,next:Maybe<&2,U32>) -> Maybe<&2,U32>:
  match selected:
    case True{}:Some{condition}
    case False{}:next
def lookup(bindings:List<&2,Binding>,+id:U32) -> Maybe<&2,U32>:
  match bindings:
    case []:None{}
    case Binding{system,condition} <> rest:binding_selected(U32.is_eq(system,id),condition,lookup(rest,id))
def binding_duplicate(found:Maybe<&2,U32>,id:U32,next:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match found:
    case Some{_}:Some{Plan.Duplicate{id}}
    case None{}:next
def valid_bindings(bindings:List<&2,Binding>,+systems:List<&2,Plan.Node<String>>,+guards:List<&2,Plan.Node<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match bindings:
    case []:None{}
    case Binding{+system,+condition} <> +rest:Plan.endpoint(~String,Plan.has(~String,systems,system),system,Plan.endpoint(~String,Plan.has(~String,guards,condition),condition,binding_duplicate(lookup(rest,system),system,valid_bindings(rest,systems,guards))))
def checked_bindings(invalid:Maybe<&2,Plan.Invalid<String>>,plan:Plan.Build<String>) -> Plan.Build<String>:
  match invalid:
    case Some{reason}:Plan.Rejected{reason}
    case None{}:plan
def checked_guards(guards:Plan.Build<String>,plan:Plan.Build<String>) -> Plan.Build<String>:
  match guards:
    case Plan.Rejected{reason}:Plan.Rejected{reason}
    case Plan.Planned{_,_}:plan

def guard_condition(~Error:Data,allowed:Bool) -> Exec.Condition<Error>:
  match allowed:
    case True{}:Exec.Allowed{}
    case False{}:Exec.Disabled{}

def dispatched(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,returned:Owners & (World & Exec.Invocation<Error,Out>),guards:Guards,handler:Handler,bindings:List<&2,Binding>) -> State<World,Owners,Guards,Handler> & Exec.Invocation<Error,Out>:
  match returned:
    case (owners,(world,status)):(State{world,owners,guards,handler,bindings},status)
def dispatch_state(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,state:State<World,Owners,Guards,Handler>,id:U32) -> State<World,Owners,Guards,Handler> & Exec.Invocation<Error,Out>:
  match state:
    case State{world,owners,guards,handler,bindings}:dispatched(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,dispatch(owners,world,id),guards,handler,bindings)
def guard_returned(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,returned:Guards & (World & Exec.Invocation<Error,Bool>),owners:Owners,handler:Handler,bindings:List<&2,Binding>) -> State<World,Owners,Guards,Handler> & Exec.Condition<Error>:
  match returned:
    case (guards,(world,Exec.Completed{output})):(State{world,owners,guards,handler,bindings},guard_condition(~Error,output))
    case (guards,(world,Exec.BodyError{error,_})):(State{world,owners,guards,handler,bindings},Exec.ConditionError{error})
    case (guards,(world,Exec.AdmissionRefused{})):(State{world,owners,guards,handler,bindings},Exec.ConditionRefused{})
def guard_selected(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,selected:Maybe<&2,U32>,state:State<World,Owners,Guards,Handler>) -> State<World,Owners,Guards,Handler> & Exec.Condition<Error>:
  match selected state:
    case None{} state:(state,Exec.Allowed{})
    case Some{id} State{world,owners,guards,handler,bindings}:guard_returned(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,guardDispatch(guards,world,id),owners,handler,bindings)
def condition_state(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,state:State<World,Owners,Guards,Handler>,id:U32) -> State<World,Owners,Guards,Handler> & Exec.Condition<Error>:
  match state:
    case State{world,owners,guards,handler,+bindings}:guard_selected(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,lookup(bindings,id),State{world,owners,guards,handler,bindings})
def handled(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,returned:Handler & Exec.Handling,world:World,owners:Owners,guards:Guards,bindings:List<&2,Binding>) -> State<World,Owners,Guards,Handler> & Exec.Handling:
  match returned:
    case (handler,action):(State{world,owners,guards,handler,bindings},action)
def handle_state(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,state:State<World,Owners,Guards,Handler>,error:Error) -> State<World,Owners,Guards,Handler> & Exec.Handling:
  match state:
    case State{world,owners,guards,handler,bindings}:handled(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,handle(handler,error),world,owners,guards,bindings)
def returned(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,result:Exec.ExecutionResult<State<World,Owners,Guards,Handler>,String,Error,Out>,plan:Plan.Build<String>,bindings:List<&2,Binding>) -> Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & Report<Error,Out>:
  match result:
    case Exec.Finished{state,events}:(Application{state,plan,bindings},Finished{events})
    case Exec.Stopped{state,error,events}:(Application{state,plan,bindings},Stopped{error,events})
    case Exec.Invalid{state,reason}:(Application{state,plan,bindings},Invalid{reason})

# Only declared System owners supply registration identity and access metadata.
# Build failure keeps every owner and refuses invocation on subsequent runs.
def build(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,~available:String -> Bool,world:World,systems:Reg.Registry<World,Owners,Error,Out,dispatch>,guards:Reg.ConditionRegistry<World,Guards,Error,guardDispatch>,handler:Handler,edges:List<&2,Plan.Edge>,+bindings:List<&2,Binding>) -> Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>:
  match systems guards:
    case Reg.Registry{owners,+nodes} Reg.ConditionRegistry{Reg.Registry{guardOwners,+guardNodes},invalid}:Application{State{world,owners,guardOwners,handler,bindings},checked_guards(checked_bindings(invalid,Plan.build(~String,~available,guardNodes,[])),checked_bindings(valid_bindings(bindings,nodes,guardNodes),Plan.build(~String,~available,nodes,edges))),bindings}
def run(~World:Type,~Owners:Type,~Guards:Type,~Handler:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),~guardDispatch:Guards -> World -> U32 -> Guards & (World & Exec.Invocation<Error,Bool>),~handle:Handler -> Error -> Handler & Exec.Handling,app:Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle>) -> Application<World,Owners,Guards,Handler,Error,Out,dispatch,guardDispatch,handle> & Report<Error,Out>:
  match app:
    case Application{state,+plan,+bindings}:returned(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle,Exec.run(~State<World,Owners,Guards,Handler>,~String,~Error,~Out,~condition_state(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle),~dispatch_state(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle),~handle_state(~World,~Owners,~Guards,~Handler,~Error,~Out,~dispatch,~guardDispatch,~handle),plan,state),plan,bindings)
