import Base
import ./world.bend as W

# Closed runner index is erased; the runtime registration owner remains affine.
type Outcome<World: Type,Error: Data,Output: Type> is Type:
  Succeeded{world: World,output: Output}
  Failed{world: World,error: Error}
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

def cursor_outcome(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,outcome: Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match outcome registry:
    case Failed{world,error} registry: Completed{registry,Failed{world,error}}
    case Succeeded{world,output} Registry{namespace,id,name,access,_}: Completed{Registry{namespace,id,name,access,nextCursor},Succeeded{world,output}}

def cursor_result(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,result: RunResult<S,C,R,E,Args,Error,Output,runner>,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  match result:
    case RegistrationRejected{registry,world,args}: RegistrationRejected{registry,world,args}
    case Completed{registry,outcome}: cursor_outcome(~S,~C,~R,~E,~Args,~Error,~Output,~runner,outcome,registry,nextCursor)

def run_to_cursor(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> Outcome<W.World<S,C,R,E>,Error,Output>,registry: Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: Args,+nextCursor: U32) -> RunResult<S,C,R,E,Args,Error,Output,runner>:
  cursor_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,run(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,args),nextCursor)
