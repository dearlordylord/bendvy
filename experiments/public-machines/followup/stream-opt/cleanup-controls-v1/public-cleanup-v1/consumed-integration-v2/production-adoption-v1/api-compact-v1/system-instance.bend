import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import system-cleanup.bend as Cleanup

# Closed schema factory indices are erased; registry and ports remain affine.
type Instance<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type,-validate: Ports -> U32 -> U32 -> Ports & Bool,-remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>> is Type:
  Instance{owned: Cleanup.Instance<S,C,R,E,Args,Error,Output,run,Ports>}
type Disposal<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type,-validate: Ports -> U32 -> U32 -> Ports & Bool,-remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>> is Type:
  Disposed{world: W.World<S,C,R,E>}
  Rejected{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>}

# Schema authors bind these indices once in their ordinary registration factory.
def bind(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,registry: Sys.Registry<S,C,R,E,Args,Error,Output,run>,ports: Ports) -> Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  Instance{Cleanup.Instance{registry,ports}}

def disposed(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,result: Cleanup.Cleanup<S,C,R,E,Args,Error,Output,run,Ports>) -> Disposal<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match result:
    case Cleanup.Cleaned{world}: Disposed{world}
    case Cleanup.CleanupRejected{world,instance}: Rejected{world,Instance{instance}}

# Callers supply only their actual instance and world; no runtime metadata callbacks.
def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>,world: W.World<S,C,R,E>) -> Disposal<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match instance:
    case Instance{owned}: disposed(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,Cleanup.cleanup(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,owned,world))

type Registration<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type,-validate: Ports -> U32 -> U32 -> Ports & Bool,-remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>> is Type:
  Registered{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>}
  RegistrationFailed{world: W.World<S,C,R,E>}

def created_ports(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,registry: Sys.Registry<S,C,R,E,Args,Error,Output,run>,observed: W.World<S,C,R,E> & Ports) -> Registration<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match observed:
    case (world,ports): Registered{world,bind(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,registry,ports)}

def created(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,~create: U32 -> U32 -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Ports,world: W.World<S,C,R,E>,namespace: U32,identified: Sys.Registry<S,C,R,E,Args,Error,Output,run> & U32) -> Registration<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match identified:
    case (registry,id): created_ports(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,registry,create(namespace,id,world))

def namespaced(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,~create: U32 -> U32 -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Ports,registry: Sys.Registry<S,C,R,E,Args,Error,Output,run>,observed: W.World<S,C,R,E> & U32) -> Registration<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match observed:
    case (world,namespace): created(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,~create,world,namespace,Sys.identity(~S,~C,~R,~E,~Args,~Error,~Output,~run,registry))

def registered(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,~create: U32 -> U32 -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Ports,result: Sys.RegistrationResult<S,C,R,E,Args,Error,Output,run>) -> Registration<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match result:
    case Sys.RegistrationFailed{world}: RegistrationFailed{world}
    case Sys.Registered{world,registry}: namespaced(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,~create,registry,W.namespace(~S,~C,~R,~E,world))

# The schema factory specializes create/validate/remove once. Failed registration
# constructs no ports; successful ports use the actual namespace and registry id.
def register(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,~create: U32 -> U32 -> W.World<S,C,R,E> -> W.World<S,C,R,E> & Ports,world: W.World<S,C,R,E>,+name: String,+access: List<&2,String>) -> Registration<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  registered(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,~create,Sys.register(~S,~C,~R,~E,~Args,~Error,~Output,~run,world,name,access))

type RunResult<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type,-validate: Ports -> U32 -> U32 -> Ports & Bool,-remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>> is Type:
  Completed{instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>,outcome: Sys.Outcome<W.World<S,C,R,E>,Error,Output>}
  RegistrationRejected{instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>,world: W.World<S,C,R,E>,args: Args}

def ran(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,ports: Ports,result: Sys.RunResult<S,C,R,E,Args,Error,Output,run>) -> RunResult<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match result:
    case Sys.Completed{registry,outcome}: Completed{bind(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,registry,ports),outcome}
    case Sys.RegistrationRejected{registry,world,args}: RegistrationRejected{bind(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,registry,ports),world,args}

# Existing tracked execution returns its registry into the same managed instance.
def run_tracked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match instance:
    case Instance{Cleanup.Instance{registry,ports}}: ran(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,ports,Sys.run_tracked(~S,~C,~R,~E,~Args,~Error,~Output,~run,registry,world,args))

# Existing untracked execution preserves callers with their own reader cursor handling.
def run(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>,world: W.World<S,C,R,E>,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,run,Ports,validate,remove>:
  match instance:
    case Instance{Cleanup.Instance{registry,ports}}: ran(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,ports,Sys.run(~S,~C,~R,~E,~Args,~Error,~Output,~run,registry,world,args))
