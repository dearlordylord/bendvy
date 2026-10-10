import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-graph.bend as Graph
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import frame.bend as F

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
def failures(~S:Data,~E:Data,+relation:G.Descriptor<S>,notices:List<&2,A.Notice<S,E>>) -> List<&2,G.Failure<S>>:
  match notices:
    case []:[]
    case notice <> rest:select_notice(~S,~E,relation,notice,failures(~S,~E,relation,rest))
def view(~S:Data,~E:Data,+relation:G.Descriptor<S>,snapshot:Ev.Snapshot<A.Notice<S,E>>) -> FailureView<S,E>:
  match snapshot:
    case Ev.Snapshot{visible,retained,_,tick,boundary}:FailureView{relation,List.reverse(&2,G.Failure<S>,failures(~S,~E,relation,visible)),List.reverse(&2,G.Failure<S>,failures(~S,~E,relation,retained)),tick,boundary}
def joined(~S:Data,~C:Type,~R:Type,~E:Data,relation:G.Descriptor<S>,cursor:U32,observed:Ev.Runtime<S,C,R,A.Notice<S,E>> & Ev.Snapshot<A.Notice<S,E>>) -> F.Frame<S,C,R,E> & FailureView<S,E>:
  (runtime,snapshot)=observed
  (F.Frame{runtime,cursor},view(~S,~E,relation,snapshot))
def read(~S:Data,~C:Type,~R:Type,~E:Data,relation:G.Descriptor<S>,frame:F.Frame<S,C,R,E>) -> F.Frame<S,C,R,E> & FailureView<S,E>:
  match frame:
    case F.Frame{runtime,cursor}:joined(~S,~C,~R,~E,relation,cursor,Ev.inspect(~S,~C,~R,~A.Notice<S,E>,runtime))
def descriptor(~S:Data,declaration:Declaration<S>) -> G.Descriptor<S>:
  match declaration:
    case Declaration{relation}:relation
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Declaration<S>) -> Cap.ValueRead<F.Frame<S,C,R,E>,FailureView<S,E>>:
  Cap.ValueRead{frame => read(~S,~C,~R,~E,descriptor(~S,declaration),frame)}
