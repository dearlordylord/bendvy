import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

type Registration<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type: Registration{reader:Ev.Reader<S>,registry:Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>}
type Defined<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  Defined{runtime:Ev.Runtime<S,C,R,E>,owner:Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>>}
  DefineRefused{runtime:Ev.Runtime<S,C,R,E>}
# Owned output transport: ordinary ScheduleDispatch itself restricts Out to Data.
type Dispatch<-S:Data,-World:Type,-Registry:Type,A:Type,Error:Data,O:Type> is Type:
  Reached{owner:Ordinary.Owner<S,Registry>,outcome:Sys.Outcome<World,Error,Unit>,values:List<O>}
  RegistrationRefused{owner:Ordinary.Owner<S,Registry>,world:World,args:A}
type Returned<S:Data,C:Type,R:Type,E:Data,A:Type,Error:Data,O:Type,-runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>> is Type: Returned{events:Domains.Events<S,E>,dispatch:Dispatch<S,W.World<S,C,R,E>,Registration<S,C,R,E,A,Error,O,runner>,A,Error,O>}
def defined(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,slot:String,clauses:List<&2,Query.Clause<S>>,result:Ev.Registered<S,C,R,E,A,Error,O,runner>) -> Defined<S,C,R,E,A,Error,O,runner>:
  match result:
    case Ev.RegisterFailed{runtime}: DefineRefused{runtime}
    case Ev.Registered{runtime,reader,registry}: Defined{runtime,Ordinary.Owner{Registration{reader,registry},slot,clauses}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,runtime:Ev.Runtime<S,C,R,E>,name:String,slot:String,+clauses:List<&2,Query.Clause<S>>) -> Defined<S,C,R,E,A,Error,O,runner>:
  defined(~S,~C,~R,~E,~A,~Error,~O,~runner,slot,clauses,Ev.register(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,name,Ordinary.access(~S,clauses)))
def detached(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,owner:Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>>,completion:Ev.Completion<Error,O,A>,returned:Domains.Detached<S,C,R,E>) -> Returned<S,C,R,E,A,Error,O,runner>:
  match completion returned:
    case Ev.Succeeded{view}, Domains.Detached{world,events}: Returned{events,Reached{owner,Sys.Succeeded{world,Unit{}},[view]}}
    case Ev.Failed{error}, Domains.Detached{world,events}: Returned{events,Reached{owner,Sys.Failed{world,error},[]}}
    case Ev.Rejected{args}, Domains.Detached{world,events}: Returned{events,RegistrationRefused{owner,world,args}}
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,slot:String,clauses:List<&2,Query.Clause<S>>,result:Ev.RunResult<S,C,R,E,A,Error,O,runner>) -> Returned<S,C,R,E,A,Error,O,runner>:
  match result:
    case Ev.Ran{runtime,reader,registry,completion}: detached(~S,~C,~R,~E,~A,~Error,~O,~runner,Ordinary.Owner{Registration{reader,registry},slot,clauses},completion,Domains.detach(~S,~C,~R,~E,runtime,[]))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,events:Domains.Events<S,E>,owner:Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>>,world:W.World<S,C,R,E>,args:A) -> Returned<S,C,R,E,A,Error,O,runner>:
  match owner:
    case Ordinary.Owner{Registration{reader,registry},slot,clauses}: completed(~S,~C,~R,~E,~A,~Error,~O,~runner,slot,clauses,Ev.run(~S,~C,~R,~E,~A,~Error,~O,~runner,Domains.attach(~S,~C,~R,~E,events,world),reader,registry,args))
def skip_detached(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,owner:Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>>,result:Domains.Detached<S,C,R,E>) -> Domains.Events<S,E> & (Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>> & W.World<S,C,R,E>):
  match result:
    case Domains.Detached{world,events}: (events,(owner,world))
def skipped(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,slot:String,clauses:List<&2,Query.Clause<S>>,registry:Sys.Registry<S,C,R,E,Ev.Input<E,A>,Error,O,runner>,result:Ev.Runtime<S,C,R,E> & Ev.Reader<S>) -> Domains.Events<S,E> & (Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>> & W.World<S,C,R,E>):
  match result:
    case (runtime,reader): skip_detached(~S,~C,~R,~E,~A,~Error,~O,~runner,Ordinary.Owner{Registration{reader,registry},slot,clauses},Domains.detach(~S,~C,~R,~E,runtime,[]))
def skip(~S:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~O:Type,~runner:W.World<S,C,R,E> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,O>,events:Domains.Events<S,E>,owner:Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>>,world:W.World<S,C,R,E>) -> Domains.Events<S,E> & (Ordinary.Owner<S,Registration<S,C,R,E,A,Error,O,runner>> & W.World<S,C,R,E>):
  match owner:
    case Ordinary.Owner{Registration{reader,registry},slot,clauses}: skipped(~S,~C,~R,~E,~A,~Error,~O,~runner,slot,clauses,registry,Ev.skip(~S,~C,~R,~E,Domains.attach(~S,~C,~R,~E,events,world),reader))
