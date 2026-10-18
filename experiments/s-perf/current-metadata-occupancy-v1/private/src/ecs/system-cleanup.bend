import Base
import world.bend as W
import system.bend as Sys

# Existing registration and every schema-authored affine reader owner travel together.
# Closed adapter templates are trusted resource integrations; no affine capture.
type Instance<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type> is Type:
  Instance{registry: Sys.Registry<S,C,R,E,Args,Error,Output,run>,ports: Ports}
type Cleanup<S: Data,C: Type,R: Type,E: Data,Args: Type,Error: Data,Output: Type,-run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,Ports: Type> is Type:
  Cleaned{world: W.World<S,C,R,E>}
  CleanupRejected{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports>}

# The sole place which removes positions is the accepted existing Sys.Disposed arm.
def disposal_result(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,ports: Ports,result: Sys.Disposal<S,C,R,E,Args,Error,Output,run>) -> Cleanup<S,C,R,E,Args,Error,Output,run,Ports>:
  match result:
    case Sys.Disposed{world}: Cleaned{remove(world,ports)}
    case Sys.DisposalRejected{world,registry}: CleanupRejected{world,Instance{registry,ports}}

def ports_checked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,registry: Sys.Registry<S,C,R,E,Args,Error,Output,run>,world: W.World<S,C,R,E>,observed: Ports & Bool) -> Cleanup<S,C,R,E,Args,Error,Output,run,Ports>:
  match observed:
    case (ports,False{}): CleanupRejected{world,Instance{registry,ports}}
    case (ports,True{}): disposal_result(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~remove,ports,Sys.dispose(~S,~C,~R,~E,~Args,~Error,~Output,~run,registry,world))

def identified(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,ports: Ports,world: W.World<S,C,R,E>,namespace: U32,observed: Sys.Registry<S,C,R,E,Args,Error,Output,run> & U32) -> Cleanup<S,C,R,E,Args,Error,Output,run,Ports>:
  match observed:
    case (registry,id): ports_checked(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~remove,registry,world,validate(ports,namespace,id))

def namespaced(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports>,observed: W.World<S,C,R,E> & U32) -> Cleanup<S,C,R,E,Args,Error,Output,run,Ports>:
  match instance observed:
    case Instance{registry,ports}, (world,namespace): identified(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,ports,world,namespace,Sys.identity(~S,~C,~R,~E,~Args,~Error,~Output,~run,registry))

def cleanup(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: Data,~Output: Type,~run: W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Output>,~Ports: Type,~validate: Ports -> U32 -> U32 -> Ports & Bool,~remove: W.World<S,C,R,E> -> Ports -> W.World<S,C,R,E>,instance: Instance<S,C,R,E,Args,Error,Output,run,Ports>,world: W.World<S,C,R,E>) -> Cleanup<S,C,R,E,Args,Error,Output,run,Ports>:
  namespaced(~S,~C,~R,~E,~Args,~Error,~Output,~run,~Ports,~validate,~remove,instance,W.namespace(~S,~C,~R,~E,world))
