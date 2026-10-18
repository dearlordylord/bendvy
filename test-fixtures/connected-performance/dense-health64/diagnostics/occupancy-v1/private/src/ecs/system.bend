import ../../../tx-metrics.bend as Metrics
import Base
import trace-facts.bend as TraceFacts
import world.bend as W
import registration.bend as Reg

# Closed runner index is erased; the runtime registration owner remains affine.
type Measurement is Data:
  Measurement{sample:Metrics.Sample,metadata:String}
type Outcome<World: Type,Error: Data,Output: Type> is Type:
  Succeeded{world: World,output: Output}
  Failed{world: World,error: Error}
  Measured{outcome:Outcome<World,Error,Output>,measurement:Measurement}
type Registry<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Registry{namespace: U32,id: U32,name: String,access: List<&2,String>,cursor: U32}
type RegistrationResult<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Registered{world: W.World<S,C,R,E>,registry: Registry<S,C,R,E,Args,Error,Output,runner>}
  RegistrationFailed{world: W.World<S,C,R,E>}
type RunResult<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Completed{registry: Registry<S,C,R,E,Args,Error,Output,runner>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>}
  RegistrationRejected{registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args}

def register_meta(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,world: W.World<S,C,R,E>,result: W.Registration,+namespace: U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case W.RegistrationRejected{_}: RegistrationFailed{world}
    case W.Registered{id}: Registered{world,Registry{namespace,id,name,access,0}}

def measured_pair(~A:Type,~World:Type,~Error:Data,~Out:Type,measurement:Measurement,result:A & Outcome<World,Error,Out>) -> A & Outcome<World,Error,Out>:
  match result:
    case (owner,outcome):(owner,Measured{outcome,measurement})
def register_join(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registered: W.World<S,C,R,E> & W.Registration,+namespace: U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  (world,result) = registered
  register_meta(~S,~C,~R,~E,~Args,~Error,~Output,~runner,world,result,namespace,name,access)

def register_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,named: W.World<S,C,R,E> & U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  (world,+namespace) = named
  register_join(~S,~C,~R,~E,~Args,~Error,~Output,~runner,W.register(~S,~C,~R,~E,world,name,access),namespace,name,access)

def register(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,world: W.World<S,C,R,E>,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  register_namespace(~S,~C,~R,~E,~Args,~Error,~Output,~runner,W.namespace(~S,~C,~R,~E,world),name,access)

def complete(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  Completed{registry,outcome}

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,allowed: Bool,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match allowed:
    case False{}: RegistrationRejected{registry,world,args}
    case True{}: complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,runner(world,args))

def run_metadata(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,checked: W.World<S,C,R,E> & Bool,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  (world,allowed) = checked
  run_checked(~S,~C,~R,~E,~Args,~Error,~Output,~runner,allowed,registry,world,args)

def run_namespace_checked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,allowed: Bool,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match allowed registry:
    case False{} registry: RegistrationRejected{registry,world,args}
    case True{} Registry{+namespace,+id,+name,+access,+cursor}: run_metadata(~S,~C,~R,~E,~Args,~Error,~Output,~runner,Registry{namespace,id,name,access,cursor},W.registration_matches(~S,~C,~R,~E,world,id,name,access),args)

def run_namespace_value(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,+actual: U32,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match registry:
    case Registry{+namespace,+id,+name,+access,+cursor}: run_namespace_checked(~S,~C,~R,~E,~Args,~Error,~Output,~runner,U32.is_eq(namespace,actual),Registry{namespace,id,name,access,cursor},world,args)

def run_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,named: W.World<S,C,R,E> & U32,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  (world,+actual) = named
  run_namespace_value(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,actual,args)

def run(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  run_namespace(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,W.namespace(~S,~C,~R,~E,world),args)

def measured_result(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,measurement:Measurement,result:RunResult<S,C,R,E,Args,Error,Output,runner>) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case Completed{registry,outcome}:Completed{registry,Measured{outcome,measurement}}
    case RegistrationRejected{registry,world,args}:RegistrationRejected{registry,world,args}
def cursor_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match outcome registry:
    case Measured{outcome,measurement} registry:measured_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,measurement,cursor_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,outcome,registry,nextCursor))
    case Failed{world,error} registry: Completed{registry,Failed{world,error}}
    case Succeeded{world,output} Registry{namespace,id,name,access,_}: Completed{Registry{namespace,id,name,access,nextCursor},Succeeded{world,output}}

def cursor_result(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,result: RunResult<S,C,R,E,Args,Error,Output,runner>,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case RegistrationRejected{registry,world,args}: RegistrationRejected{registry,world,args}
    case Completed{registry,outcome}: cursor_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,outcome,registry,nextCursor)

def run_to_cursor(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  cursor_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,run(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,args),nextCursor)

# A successful tracked reader consumes every component stamp committed during
# its own run. Failed/rejected runs preserve the existing reader cursor.
def tracked_clock(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,output: Output,observed: W.World<S,C,R,E> & U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  (world,clock) = observed
  cursor_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,Succeeded{world,output},registry,clock)

def tracked_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match outcome:
    case Measured{outcome,measurement}:measured_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,measurement,tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,outcome))
    case Failed{world,error}: Completed{registry,Failed{world,error}}
    case Succeeded{world,output}: tracked_clock(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,output,W.clock(~S,~C,~R,~E,world))

def tracked_result(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,result: RunResult<S,C,R,E,Args,Error,Output,runner>) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case RegistrationRejected{registry,world,args}: RegistrationRejected{registry,world,args}
    case Completed{registry,outcome}: tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,outcome)

def run_tracked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  tracked_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,run(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,args))

def cursor(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>) -> Registry<S,C,R,E,Args,Error,Output,runner> & U32:
  match registry:
    case Registry{+namespace,+id,+name,+access,+cursor}: (Registry{namespace,id,name,access,cursor},cursor)

# Instance identity is observed without consuming the registration owner.
def identity(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>) -> Registry<S,C,R,E,Args,Error,Output,runner> & U32:
  match registry:
    case Registry{namespace,+id,name,access,cursor}: (Registry{namespace,id,name,access,cursor},id)

# Rejected disposal returns the registration; accepted disposal consumes it.
type Disposal<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Disposed{world: W.World<S,C,R,E>}
  DisposalRejected{world: W.World<S,C,R,E>,registry: Registry<S,C,R,E,Args,Error,Output,runner>}

def dispose_returned(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,observed: W.World<S,C,R,E> & Bool) -> Disposal<S,C,R,E,Args,Error,Output,runner>:
  match observed:
    case (world,True{}): Disposed{world}
    case (world,False{}): DisposalRejected{world,registry}

def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>) -> Disposal<S,C,R,E,Args,Error,Output,runner>:
  match registry:
    case Registry{+namespace,+id,+name,+access,cursor}: dispose_returned(~S,~C,~R,~E,~Args,~Error,~Output,~runner,Registry{namespace,id,name,access,cursor},Reg.remove(~S,~C,~R,~E,world,namespace,id,name,access))

# Trusted canonical runner transport. Registration is checked before the body.
def observed_outcome_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,result:Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match result:
    case (outcome,trace):(finish(registry,outcome),trace)
def observed_checked_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,checked:W.World<S,C,R,E> & Bool,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match checked:
    case (world,False{}):(RegistrationRejected{registry,world,args},trace)
    case (world,True{}):observed_outcome_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,registry,observed(trace,world,args))
def observed_namespace_checked_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args,allowed:Bool) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match registry allowed:
    case registry False{}:(RegistrationRejected{registry,world,args},trace)
    case Registry{+namespace,+id,+name,+access,+cursor} True{}:observed_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,Registry{namespace,id,name,access,cursor},trace,W.registration_matches(~S,~C,~R,~E,world,id,name,access),args)
def observed_named_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,named:W.World<S,C,R,E> & U32,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match registry named:
    case Registry{+namespace,+id,+name,+access,+cursor}, (world,actual):observed_namespace_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,Registry{namespace,id,name,access,cursor},trace,world,args,U32.is_eq(namespace,actual))
def run_observed_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_named_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,registry,trace,W.namespace(~S,~C,~R,~E,world),args)

def observed_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,result:Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_outcome_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,result)
def observed_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,checked:W.World<S,C,R,E> & Bool,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,checked,args)
def observed_namespace_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args,allowed:Bool) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_namespace_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,world,args,allowed)
def observed_named(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,named:W.World<S,C,R,E> & U32,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_named_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,named,args)
def run_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  run_observed_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~tracked_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,world,args)

def run_observed_untracked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  run_observed_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,world,args)
