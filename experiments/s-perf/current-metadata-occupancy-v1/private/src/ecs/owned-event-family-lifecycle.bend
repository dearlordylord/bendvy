import Base
import ./world.bend as W
import ./system.bend as Sys
import ./event-runtime.bend as Ev
import ./event-stream.bend as Stream
import ./event-family-routing.bend as Route

# Raw selectors are trusted engine bindings. Ordinary Setup derives matching paths.
# Skip does not activate an absent position; disposal removes only after Sys validation.
def position(~S:Data,stream:Stream.Stream<S,Nat>,id:U32,tick:Nat,dispose:Bool) -> Stream.Stream<S,Nat>:
  match stream:
    case Stream.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream.Stream{domain,batches,Ev.update(positions,id,tick,dispose),nextReader,frameStart,boundary,capacity,dropped}
def positioned(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,world:W.World<S,C,R,E>,+tick:Nat,id:U32,dispose:Bool,returned:F & Stream.Stream<S,Nat>) -> Route.Runtime<S,C,R,E,F>:
  match returned:
    case (family,stream):Route.Runtime{world,put(family,position(~S,stream,id,tick,dispose)),tick}
def skip_checked(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,allowed:Bool,runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>,id:U32) -> Route.Runtime<S,C,R,E,F> & Route.Reader<S,Nat,F,take,put>:
  match allowed runtime:
    case False{} runtime:(runtime,reader)
    case True{} Route.Runtime{world,family,+tick}:(positioned(~S,~C,~R,~E,~F,~take,~put,world,tick,id,False{},take(family)),reader)
def skip_named(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,family:F,tick:Nat,reader:Route.Reader<S,Nat,F,take,put>,named:W.World<S,C,R,E> & U32) -> Route.Runtime<S,C,R,E,F> & Route.Reader<S,Nat,F,take,put>:
  match reader named:
    case Route.Reader{+namespace,+id,+registryId}, (world,+actual):skip_checked(~S,~C,~R,~E,~F,~take,~put,U32.is_eq(actual,namespace),Route.Runtime{world,family,tick},Route.Reader{namespace,id,registryId},id)
def skip(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>) -> Route.Runtime<S,C,R,E,F> & Route.Reader<S,Nat,F,take,put>:
  match runtime:
    case Route.Runtime{world,family,tick}:skip_named(~S,~C,~R,~E,~F,~take,~put,family,tick,reader,W.namespace(~S,~C,~R,~E,world))
type Disposal<S:Data,C:Type,R:Type,E:Data,F:Type,Args:Type,Error:Data,Out:Type,-take:F -> F & Stream.Stream<S,Nat>,-put:F -> Stream.Stream<S,Nat> -> F,-runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>> is Type:
  Disposed{runtime:Route.Runtime<S,C,R,E,F>}
  DisposalRejected{runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner>}
def disposed(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,family:F,tick:Nat,reader:Route.Reader<S,Nat,F,take,put>,id:U32,result:Sys.Disposal<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner>) -> Disposal<S,C,R,E,F,Args,Error,Out,take,put,runner>:
  match result:
    case Sys.Disposed{world}:Disposed{positioned(~S,~C,~R,~E,~F,~take,~put,world,tick,id,True{},take(family))}
    case Sys.DisposalRejected{world,registry}:DisposalRejected{Route.Runtime{world,family,tick},reader,registry}
def dispose_checked(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,allowed:Bool,world:W.World<S,C,R,E>,family:F,tick:Nat,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner>,id:U32) -> Disposal<S,C,R,E,F,Args,Error,Out,take,put,runner>:
  match allowed:
    case False{}:DisposalRejected{Route.Runtime{world,family,tick},reader,registry}
    case True{}:disposed(~S,~C,~R,~E,~F,~take,~put,~Args,~Error,~Out,~runner,family,tick,reader,id,Sys.dispose(~S,~C,~R,~E,~Ev.Input<Nat,Args>,~Error,~Out,~runner,registry,world))
def dispose_named(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,family:F,tick:Nat,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner>,actualId:U32,named:W.World<S,C,R,E> & U32) -> Disposal<S,C,R,E,F,Args,Error,Out,take,put,runner>:
  match reader named:
    case Route.Reader{+namespace,+id,+registryId}, (world,+actualNamespace):dispose_checked(~S,~C,~R,~E,~F,~take,~put,~Args,~Error,~Out,~runner,Bool.and(U32.is_eq(actualNamespace,namespace),U32.is_eq(actualId,registryId)),world,family,tick,Route.Reader{namespace,id,registryId},registry,id)
def dispose_identified(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>,identified:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner> & U32) -> Disposal<S,C,R,E,F,Args,Error,Out,take,put,runner>:
  match runtime identified:
    case Route.Runtime{world,family,tick}, (registry,id):dispose_named(~S,~C,~R,~E,~F,~take,~put,~Args,~Error,~Out,~runner,family,tick,reader,registry,id,W.namespace(~S,~C,~R,~E,world))
def dispose(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~Args:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> Ev.Input<Nat,Args> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Error,Out,runner>) -> Disposal<S,C,R,E,F,Args,Error,Out,take,put,runner>:
  dispose_identified(~S,~C,~R,~E,~F,~take,~put,~Args,~Error,~Out,~runner,runtime,reader,Sys.identity(~S,~C,~R,~E,~Ev.Input<Nat,Args>,~Error,~Out,~runner,registry))
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,world:W.World<S,C,R,E>,tick:Nat,returned:F & Stream.Stream<S,Nat>) -> Route.Runtime<S,C,R,E,F> & Stream.Stream<S,Nat>:
  match returned:
    case (family,stream):(Route.Runtime{world,family,tick},stream)
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,runtime:Route.Runtime<S,C,R,E,F>) -> Route.Runtime<S,C,R,E,F> & Stream.Stream<S,Nat>:
  match runtime:
    case Route.Runtime{world,family,tick}:selected(~S,~C,~R,~E,~F,~take,~put,world,tick,take(family))
