import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./event-runtime.bend as Ev
import ./machine-stream.bend as St
import ./relation-commands.bend as A
import ./capabilities.bend as Cap
import ./inspector-stream-frame.bend as F

# Declares a named transition-log projection. K and the resource lens take
# determine the stream; name is presentation metadata, not access validation.
type Declaration<S:Data,K:Data,V:Data,R:Type,-take:R -> R & St.Stream<V>> is Data:
  Declaration{name:String}
# Detached Data observation of a machine transition stream, not its owner.
type TransitionLog<S:Data,K:Data,V:Data> is Data:
  TransitionLog{stream:St.Stream<V>}
def joined(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,cursor:Maybe<&2,Tick.Tick>,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat,observed:W.World<S,C,R,A.Notice<S,E>> & St.Stream<V>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  (world,stream)=observed
  (F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},cursor},TransitionLog{stream})
# Observe the stream through the trusted resource lens and return the runtime
# in an Inspector frame. Preserve event batches, reader positions and cursor.
# The lens must return the resource owner with the intended stream observation.
def from_runtime(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,cursor:Maybe<&2,Tick.Tick>,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  match runtime:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:joined(~S,~K,~V,~C,~R,~E,cursor,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,W.observe_resource(~S,~C,~R,~A.Notice<S,E>,~St.Stream<V>,~take,world))
# Read the declared resource stream without executing a transition or advancing
# an event reader. Return the affine frame and its detached transition log.
def read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,frame:F.Frame<S,C,R,E>) -> F.Frame<S,C,R,E> & TransitionLog<S,K,V>:
  match frame:
    case F.Frame{runtime,cursor}:from_runtime(~S,~K,~V,~C,~R,~E,~take,cursor,runtime)
# Build a read capability using the declaration's typed resource lens. The
# declaration name does not select a different stream or enforce lens behavior.
def inspect(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,~declaration:Declaration<S,K,V,R,take>) -> Cap.ValueRead<F.Frame<S,C,R,E>,TransitionLog<S,K,V>>:
  Cap.ValueRead{read(~S,~K,~V,~C,~R,~E,~take)}
