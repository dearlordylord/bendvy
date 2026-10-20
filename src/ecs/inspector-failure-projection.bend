import Base
import ./change-tick.bend as Tick
import ./event-runtime.bend as Ev
import ./relation-commands.bend as A
import ./relation-types.bend as G
import ./relation-graph.bend as Graph
import ./capabilities.bend as Cap
import ./inspector-stream-frame.bend as F

# Selects a relation failure projection by descriptor key. The descriptor must
# belong to the application schema; this raw declaration does not validate it.
type Declaration<S:Data> is Data:
  Declaration{relation:G.Descriptor<S>}
# This declaration-scoped grant exposes selected failures and non-payload
# timing only. Shared Notice payloads and reader counts stay in the owner harness.
type FailureView<S:Data,E:Data> is Data:
  FailureView{relation:G.Descriptor<S>,visible:List<&2,G.Failure<S>>,retained:List<&2,G.Failure<S>>,tick:Nat,boundary:Nat}
def selected(~S:Data,keep:Bool,failure:G.Failure<S>,rest:List<&2,G.Failure<S>>) -> List<&2,G.Failure<S>>:
  match keep:
    case False{}:rest
    case True{}:failure <> rest
def select_failure(~S:Data,+relation:G.Descriptor<S>,+failure:G.Failure<S>,rest:List<&2,G.Failure<S>>) -> List<&2,G.Failure<S>>:
  match failure:
    case G.Failure{+actual,operation,source,target,error}:selected(~S,U32.is_eq(Graph.key(~S,actual),Graph.key(~S,relation)),G.Failure{actual,operation,source,target,error},rest)
def select_notice(~S:Data,~E:Data,relation:G.Descriptor<S>,notice:A.Notice<S,E>,rest:List<&2,G.Failure<S>>) -> List<&2,G.Failure<S>>:
  match notice:
    case A.RelationFailed{failure}:select_failure(~S,relation,failure,rest)
    case _:rest
# Extract relation failures matching the descriptor key, preserving notice order.
# Other notice variants are omitted; no payload owners or reader positions change.
def failures(~S:Data,~E:Data,+relation:G.Descriptor<S>,notices:List<&2,A.Notice<S,E>>) -> List<&2,G.Failure<S>>:
  match notices:
    case []:[]
    case notice <> rest:select_notice(~S,~E,relation,notice,failures(~S,~E,relation,rest))
# Project visible and retained failures separately from a detached snapshot.
# Preserve its tick and retention boundary; this does not acknowledge a reader.
def view(~S:Data,~E:Data,+relation:G.Descriptor<S>,snapshot:Ev.Snapshot<A.Notice<S,E>>) -> FailureView<S,E>:
  match snapshot:
    case Ev.Snapshot{visible,retained,_,tick,boundary}:FailureView{relation,failures(~S,~E,relation,visible),failures(~S,~E,relation,retained),tick,boundary}
def joined(~S:Data,~C:Type,~R:Type,~E:Data,relation:G.Descriptor<S>,cursor:Maybe<&2,Tick.Tick>,observed:Ev.Runtime<S,C,R,A.Notice<S,E>> & Ev.Snapshot<A.Notice<S,E>>) -> F.Frame<S,C,R,E> & FailureView<S,E>:
  (runtime,snapshot)=observed
  (F.Frame{runtime,cursor},view(~S,~E,relation,snapshot))
# Return the runtime frame with a detached failure view. Preserve the Inspector
# cursor and runtime reader positions; inspection does not drain retained notices.
def read(~S:Data,~C:Type,~R:Type,~E:Data,relation:G.Descriptor<S>,frame:F.Frame<S,C,R,E>) -> F.Frame<S,C,R,E> & FailureView<S,E>:
  match frame:
    case F.Frame{runtime,cursor}:joined(~S,~C,~R,~E,relation,cursor,Ev.inspect(~S,~C,~R,~A.Notice<S,E>,runtime))
# Recover the descriptor carried by this declaration, without validation.
def descriptor(~S:Data,declaration:Declaration<S>) -> G.Descriptor<S>:
  match declaration:
    case Declaration{relation}:relation
# Build the read capability for this declaration. It exposes only selected
# failures and timing metadata, returning the affine frame after inspection.
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Declaration<S>) -> Cap.ValueRead<F.Frame<S,C,R,E>,FailureView<S,E>>:
  Cap.ValueRead{frame => read(~S,~C,~R,~E,descriptor(~S,declaration),frame)}
