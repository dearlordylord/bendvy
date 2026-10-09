import Base
import ./frame.bend as F
import ./request.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as World
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity

# Trusted traversal kernel. A is an explicit application-owned state threaded
# once across selected rows; the Local adapter retains it on system failure.
# Data row observations stay commit-only. This is not a new captures policy.
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,next:Request.Owner<S,C,R,E,P,identity,project> -> A -> List<&2,Out> -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),owner:Request.Owner<S,C,R,E,P,identity,project>,state:A,values:List<&2,Out>,result:T.Outcome<Query.Error<U>>) -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match result:
    case T.Failure{error}:(owner,(state,(T.Failure{error},[])))
    case T.Success{}:next(owner,state,values)

def returned(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,next:Request.Owner<S,C,R,E,P,identity,project> -> A -> List<&2,Out> -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),values:List<&2,Out>,observed:F.Frame<S,C,R,E,P,identity,project> & (A & (T.Outcome<U> & Out))) -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match observed:
    case (F.Frame{owner,_,error,_},(state,(outcome,value))):completed(~S,~C,~R,~E,~P,~A,~U,~Out,~Ops,~identity,~project,next,owner,state,value <> values,Query.outcome(~U,error,outcome))

def selected(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~grants:Ops(F.Frame<S,C,R,E,P,identity,project>),~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (A & (T.Outcome<U> & Out)),next:Request.Owner<S,C,R,E,P,identity,project> -> A -> List<&2,Out> -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),state:A,values:List<&2,Out>,observed:F.Frame<S,C,R,E,P,identity,project> & Bool) -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match observed:
    case (F.Frame{owner,_,_,_},False{}):next(owner,state,values)
    case (frame,True{}):returned(~S,~C,~R,~E,~P,~A,~U,~Out,~Ops,~identity,~project,next,values,Cap.invoke_owned(~Ops,~A,~(A & (T.Outcome<U> & Out)),~body,~F.Frame<S,C,R,E,P,identity,project>,~grants,state,frame))

def run_rows(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~selector:F.Frame<S,C,R,E,P,identity,project> -> F.Frame<S,C,R,E,P,identity,project> & Bool,~grants:Ops(F.Frame<S,C,R,E,P,identity,project>),~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (A & (T.Outcome<U> & Out)),handles:List<&2,World.Handle<S>>,+cursor:U32,owner:Request.Owner<S,C,R,E,P,identity,project>,state:A,values:List<&2,Out>) -> Request.Owner<S,C,R,E,P,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match handles:
    case []:(owner,(state,(T.Success{},List.reverse(&2,Out,values))))
    case handle <> rest:selected(~S,~C,~R,~E,~P,~A,~U,~Out,~Ops,~identity,~project,~grants,~body,(owner => state => values => run_rows(~S,~C,~R,~E,~P,~A,~U,~Out,~Ops,~identity,~project,~selector,~grants,~body,rest,cursor,owner,state,values)),state,values,selector(F.Frame{owner,handle,None{},cursor}))
