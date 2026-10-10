import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import stream-mutant.bend as Leaf

# F is any finite generated product of typed stream leaves and affine owners.
type Runtime<S:Data,C:Type,R:Type,P:Data,F:Type> is Type:
  Runtime{world:W.World<S,C,R,P>,family:F,tick:Nat}
type Reader<S:Data,E:Data,F:Type,-take:F -> F & Leaf.Stream<S,E>,-put:F -> Leaf.Stream<S,E> -> F> is Type:
  Reader{namespace:U32,id:U32,registryId:U32}
type Registration<S:Data,C:Type,R:Type,P:Data,E:Data,F:Type,A:Type,Error:Data,O:Type,-take:F -> F & Leaf.Stream<S,E>,-put:F -> Leaf.Stream<S,E> -> F,-runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>> is Type:
  Registered{runtime:Runtime<S,C,R,P,F>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>}
  RegistrationFailed{runtime:Runtime<S,C,R,P,F>}
def registration_identity(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,world:W.World<S,C,R,P>,family:F,+tick:Nat,+namespace:U32,returned:Leaf.Stream<S,E> & U32,identified:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner> & U32) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  (stream,id)=returned
  (registry,registryId)=identified
  Registered{Runtime{world,put(family,stream),tick},Reader{namespace,id,registryId},registry}
def registration_result(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,family:F,+stream:Leaf.Stream<S,E>,+tick:Nat,+namespace:U32,result:Sys.RegistrationResult<S,C,R,P,Ev.Input<E,A>,Error,O,runner>) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match result:
    case Sys.RegistrationFailed{world}:RegistrationFailed{Runtime{world,put(family,stream),tick}}
    case Sys.Registered{world,registry}:registration_identity(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,world,family,tick,namespace,Leaf.registered(~S,~E,stream,tick),Sys.identity(~S,~C,~R,~P,~Ev.Input<E,A>,~Error,~O,~runner,registry))
def registration_namespace(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,family:F,stream:Leaf.Stream<S,E>,tick:Nat,declaration:Event.Declaration<S,E>,+name:String,world:W.World<S,C,R,P>,namespace:U32) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match declaration:
    case Event.Declaration{_,Event.Write{}}:RegistrationFailed{Runtime{world,put(family,stream),tick}}
    case Event.Declaration{+domain,Event.Read{}}:registration_result(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,family,stream,tick,namespace,Sys.register(~S,~C,~R,~P,~Ev.Input<E,A>,~Error,~O,~runner,world,name,[Event.access(~S,~E,Event.Declaration{domain,Event.Read{}})]))
def registration_named(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,family:F,stream:Leaf.Stream<S,E>,tick:Nat,declaration:Event.Declaration<S,E>,name:String,named:W.World<S,C,R,P> & U32) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match named:
    case (world,namespace):registration_namespace(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,family,stream,tick,declaration,name,world,namespace)
def registration_leaf(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,world:W.World<S,C,R,P>,tick:Nat,name:String,returned:F & Leaf.Stream<S,E>) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match returned:
    case (family,+stream):registration_named(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,family,stream,tick,Leaf.read_declaration(~S,~E,stream),name,W.namespace(~S,~C,~R,~P,world))
def register(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,runtime:Runtime<S,C,R,P,F>,name:String) -> Registration<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match runtime:
    case Runtime{world,family,tick}:registration_leaf(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,world,tick,name,take(family))

type RunResult<S:Data,C:Type,R:Type,P:Data,E:Data,F:Type,A:Type,Error:Data,O:Type,-take:F -> F & Leaf.Stream<S,E>,-put:F -> Leaf.Stream<S,E> -> F,-runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>> is Type:
  Ran{runtime:Runtime<S,C,R,P,F>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,completion:Ev.Completion<Error,O,A>}
def run_synchronized(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,tick:Nat,output:O,returned:W.World<S,C,R,P> & F) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match returned:
    case (world,family):Ran{Runtime{world,family,tick},reader,registry,Ev.Succeeded{output}}
def run_outcome(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,family:F,+stream:Leaf.Stream<S,E>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,+id:U32,+tick:Nat,outcome:Sys.Outcome<W.World<S,C,R,P>,Error,O>) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match outcome:
    case Sys.Failed{world,error}:Ran{Runtime{world,put(family,Leaf.completed(~S,~E,stream,id,1n+tick,False{})),1n+tick},reader,registry,Ev.Failed{error}}
    case Sys.Succeeded{world,output}:run_synchronized(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,reader,registry,1n+tick,output,synchronize(world,put(family,Leaf.completed(~S,~E,stream,id,1n+tick,True{})),1n+tick))
def run_result(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,family:F,stream:Leaf.Stream<S,E>,reader:Reader<S,E,F,take,put>,id:U32,tick:Nat,result:Sys.RunResult<S,C,R,P,Ev.Input<E,A>,Error,O,runner>) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match result:
    case Sys.RegistrationRejected{registry,world,Ev.Input{_,_,args}}:Ran{Runtime{world,put(family,stream),1n+tick},reader,registry,Ev.Rejected{args}}
    case Sys.Completed{registry,outcome}:run_outcome(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,family,stream,reader,registry,id,tick,outcome)
def run_reading(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,world:W.World<S,C,R,P>,family:F,stream:Leaf.Stream<S,E>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,id:U32,tick:Nat,args:A,reading:Ev.Reading<E>) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match reading:
    case Ev.Reading{values,lagged}:run_result(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,family,stream,reader,id,tick,Sys.run(~S,~C,~R,~P,~Ev.Input<E,A>,~Error,~O,~runner,registry,world,Ev.Input{values,lagged,args}))
def run_leaf_reading(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,world:W.World<S,C,R,P>,family:F,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,id:U32,tick:Nat,args:A,returned:Leaf.Stream<S,E> & Ev.Reading<E>) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match returned:
    case (stream,reading):run_reading(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,world,family,stream,reader,registry,id,tick,args,reading)
def run_leaf(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,world:W.World<S,C,R,P>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,+id:U32,+tick:Nat,args:A,returned:F & Leaf.Stream<S,E>) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match returned:
    case (family,stream):run_leaf_reading(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,world,family,reader,registry,id,tick,args,Leaf.reading(~S,~E,stream,id,tick))
def run_checked(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,allowed:Bool,world:W.World<S,C,R,P>,family:F,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,id:U32,tick:Nat,args:A) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match allowed:
    case False{}:Ran{Runtime{world,family,tick},reader,registry,Ev.Rejected{args}}
    case True{}:run_leaf(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,world,reader,registry,id,tick,args,take(family))
def run_identity(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,family:F,tick:Nat,args:A,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,actual:U32,named:W.World<S,C,R,P> & U32) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match reader:
    case Reader{+namespace,+id,+registryId}:
      (world,actualNamespace)=named
      run_checked(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,Bool.and(U32.is_eq(namespace,actualNamespace),U32.is_eq(registryId,actual)),world,family,Reader{namespace,id,registryId},registry,id,tick,args)
def run_identified(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,runtime:Runtime<S,C,R,P,F>,reader:Reader<S,E,F,take,put>,args:A,identified:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner> & U32) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  match runtime:
    case Runtime{world,family,tick}:
      (registry,actual)=identified
      run_identity(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,family,tick,args,reader,registry,actual,W.namespace(~S,~C,~R,~P,world))
def run(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~A:Type,~Error:Data,~O:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,~runner:W.World<S,C,R,P> -> Ev.Input<E,A> -> Sys.Outcome<W.World<S,C,R,P>,Error,O>,~synchronize:W.World<S,C,R,P> -> F -> Nat -> W.World<S,C,R,P> & F,runtime:Runtime<S,C,R,P,F>,reader:Reader<S,E,F,take,put>,registry:Sys.Registry<S,C,R,P,Ev.Input<E,A>,Error,O,runner>,args:A) -> RunResult<S,C,R,P,E,F,A,Error,O,take,put,runner>:
  run_identified(~S,~C,~R,~P,~E,~F,~A,~Error,~O,~take,~put,~runner,~synchronize,runtime,reader,args,Sys.identity(~S,~C,~R,~P,~Ev.Input<E,A>,~Error,~O,~runner,registry))
