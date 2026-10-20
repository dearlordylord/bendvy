import Base
import ./change-tick.bend as Tick
import ./trace-facts.bend as TraceFacts
import ./world.bend as W
import ./registration.bend as Reg

# Closed runner index is erased; the runtime registration owner remains affine.
# System completion retains World on both branches. Success also owns
# Output; failure carries only Error, so affine body outputs are not returned
# by this type. Rollback is performed by the chosen runner, not this constructor.
type Outcome<World: Type,Error: Data,Output: Type> is Type:
  Succeeded{world: World,output: Output}
  Failed{world: World,error: Error}
# Affine registration owner with runtime namespace, actual registration ID,
# metadata and lifecycle cursor. The erased runner binds argument/result types;
# raw construction is trusted administration, not a way to confer gameplay access.
type Registry<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Registry{namespace: U32,id: U32,name: String,access: List<&2,String>,cursor: Maybe<&2,Tick.Tick>}
# Registered returns World and the new Registry; RegistrationFailed returns
# World without a registration owner. Registration does not invoke the runner.
type RegistrationResult<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Registered{world: W.World<S,C,R,E>,registry: Registry<S,C,R,E,Args,Error,Output,runner>}
  RegistrationFailed{world: W.World<S,C,R,E>}
# Completed retains Registry and a runner Outcome. RegistrationRejected
# retains Registry, World and original Args without invoking the runner.
# Rejection is distinct from a body failure that has consumed Args.
type RunResult<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Completed{registry: Registry<S,C,R,E,Args,Error,Output,runner>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>}
  RegistrationRejected{registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args}

def register_meta(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,world: W.World<S,C,R,E>,result: W.Registration,+namespace: U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case W.RegistrationRejected{_}: RegistrationFailed{world}
    case W.Registered{id}: Registered{world,Registry{namespace,id,name,access,None{}}}

def register_join(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registered: W.World<S,C,R,E> & W.Registration,+namespace: U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  (world,result) = registered
  register_meta(~S,~C,~R,~E,~Args,~Error,~Output,~runner,world,result,namespace,name,access)

def register_namespace(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,named: W.World<S,C,R,E> & U32,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  (world,+namespace) = named
  register_join(~S,~C,~R,~E,~Args,~Error,~Output,~runner,W.register(~S,~C,~R,~E,world,name,access),namespace,name,access)

# Register the closed runner in this World with name/access metadata.
# Returns Registered or RegistrationFailed, retaining World on either path.
# Raw access strings are metadata; actual body capabilities come from its
# declared runner. Prefer ordinary-system or App registration for derived access.
def register(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,world: W.World<S,C,R,E>,+name: String,+access: List<&2,String>) -> RegistrationResult<S,C,R,E,Args,Error,Output,runner>:
  register_namespace(~S,~C,~R,~E,~Args,~Error,~Output,~runner,W.namespace(~S,~C,~R,~E,world),name,access)

def complete(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  Completed{registry,outcome}

# Leave the captured scope on either executed outcome; never rewind time.
def leave_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,outcome:Outcome<W.World<S,C,R,E>,Error,Output>) -> Outcome<W.World<S,C,R,E>,Error,Output>:
  match outcome:
    case Succeeded{world,output}:Succeeded{W.leave_run(~S,~C,~R,~E,world),output}
    case Failed{world,error}:Failed{W.leave_run(~S,~C,~R,~E,world),error}

def executed_registry(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,tick:Tick.Tick) -> Registry<S,C,R,E,Args,Error,Output,runner>:
  match registry:
    case Registry{namespace,id,name,access,_}:Registry{namespace,id,name,access,Some{tick}}

def run_entered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,args:Args,entered:W.World<S,C,R,E> & Tick.Tick) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  (world,tick)=entered
  complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner,executed_registry(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,tick),leave_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,runner(world,args)))

def run_checked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,allowed: Bool,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match allowed:
    case False{}: RegistrationRejected{registry,world,args}
    case True{}: run_entered(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,args,W.enter_run(~S,~C,~R,~E,world))

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

# Validate runtime namespace and live registration metadata, then invoke
# the runner. Rejection returns original Args, World and Registry unchanged
# in ownership; completed failure returns only the runner Error/World.
# Every admitted execution captures this_run and records it on success or error.
# Rejection leaves time/cursor unchanged. Runner defines rollback behavior.
def run(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  run_namespace(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,W.namespace(~S,~C,~R,~E,world),args)

# Return Registry and its current lifecycle cursor, without advancing it
# or reading any component/event stream.
def cursor(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>) -> Registry<S,C,R,E,Args,Error,Output,runner> & Maybe<&2,Tick.Tick>:
  match registry:
    case Registry{+namespace,+id,+name,+access,+cursor}: (Registry{namespace,id,name,access,cursor},cursor)

# Instance identity is observed without consuming the registration owner.
# Return Registry and its actual registration ID without consuming the owner.
# IDs must still be validated with namespace/live metadata before execution.
def identity(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>) -> Registry<S,C,R,E,Args,Error,Output,runner> & U32:
  match registry:
    case Registry{namespace,+id,name,access,cursor}: (Registry{namespace,id,name,access,cursor},id)

# Rejected disposal returns the registration; accepted disposal consumes it.
# Disposed returns World and consumes this registration owner.
# DisposalRejected returns World and Registry for retry or explicit recovery.
# This type introduces no user-payload finalizer or capture-disposal callback.
type Disposal<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>> is Type:
  Disposed{world: W.World<S,C,R,E>}
  DisposalRejected{world: W.World<S,C,R,E>,registry: Registry<S,C,R,E,Args,Error,Output,runner>}

def dispose_returned(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,observed: W.World<S,C,R,E> & Bool) -> Disposal<S,C,R,E,Args,Error,Output,runner>:
  match observed:
    case (world,True{}): Disposed{world}
    case (world,False{}): DisposalRejected{world,registry}

# Remove a registration only when its namespace/ID/name/access still match.
# Success consumes Registry; refusal returns it with World. Does not dispose
# unrelated retained Local/capture owners or invent implicit finalizers.
def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>) -> Disposal<S,C,R,E,Args,Error,Output,runner>:
  match registry:
    case Registry{+namespace,+id,+name,+access,cursor}: dispose_returned(~S,~C,~R,~E,~Args,~Error,~Output,~runner,Registry{namespace,id,name,access,cursor},Reg.remove(~S,~C,~R,~E,world,namespace,id,name,access))

# Trusted canonical runner transport. Registration is checked before the body.
def observed_outcome_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,result:Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match result:
    case (outcome,trace):(finish(registry,leave_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,outcome)),trace)
def observed_entered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,args:Args,entered:W.World<S,C,R,E> & Tick.Tick) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  (world,tick)=entered
  observed_outcome_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,executed_registry(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,tick),observed(trace,world,args))
def observed_checked_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,checked:W.World<S,C,R,E> & Bool,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match checked:
    case (world,False{}):(RegistrationRejected{registry,world,args},trace)
    case (world,True{}):observed_entered(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,registry,trace,args,W.enter_run(~S,~C,~R,~E,world))
def observed_namespace_checked_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args,allowed:Bool) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match registry allowed:
    case registry False{}:(RegistrationRejected{registry,world,args},trace)
    case Registry{+namespace,+id,+name,+access,+cursor} True{}:observed_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,Registry{namespace,id,name,access,cursor},trace,W.registration_matches(~S,~C,~R,~E,world,id,name,access),args)
def observed_named_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,named:W.World<S,C,R,E> & U32,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  match registry named:
    case Registry{+namespace,+id,+name,+access,+cursor}, (world,actual):observed_namespace_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,Registry{namespace,id,name,access,cursor},trace,world,args,U32.is_eq(namespace,actual))
# Trusted transport for an observed runner and custom completion policy.
# Validates registration before invoking observed; refusal returns original
# Args/owners and trace. finish receives the executed cursor; raw callbacks must
# preserve their relationship to runner and its transaction contract.
def run_observed_with(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,~finish:Registry<S,C,R,E,Args,Error,Output,runner> -> Outcome<W.World<S,C,R,E>,Error,Output> -> RunResult<S,C,R,E,Args,Error,Output,runner>,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_named_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~finish,registry,trace,W.namespace(~S,~C,~R,~E,world),args)

def observed_outcome(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,result:Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_outcome_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,result)
def observed_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,checked:W.World<S,C,R,E> & Bool,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,checked,args)
def observed_namespace_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args,allowed:Bool) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_namespace_checked_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,world,args,allowed)
def observed_named(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,named:W.World<S,C,R,E> & U32,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  observed_named_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,named,args)
# Observed execution captures and records this_run on success or failure.
# Refusal preserves Args, time, cursor and trace.
# Returned facts describe execution, not additional ECS work to apply.
def run_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,~observed:TraceFacts.State -> W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output> & TraceFacts.State,registry:Registry<S,C,R,E,Args,Error,Output,runner>,trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> RunResult<S,C,R,E,Args,Error,Output,runner> & TraceFacts.State:
  run_observed_with(~S,~C,~R,~E,~Args,~Error,~Output,~runner,~observed,~complete(~S,~C,~R,~E,~Args,~Error,~Output,~runner),registry,trace,world,args)
