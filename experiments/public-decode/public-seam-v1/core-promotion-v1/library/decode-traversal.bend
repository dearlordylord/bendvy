import Base
import ./decode-frame.bend as F
import ./decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as World
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../dependencies/snapshot/decode-data.bend as D
import ../dependencies/snapshot/ordinary-declaration.bend as Identity

# Trusted traversal kernel. A is an explicit application-owned state threaded
# once across selected rows; the Local adapter retains it on system failure.
# Data row observations stay commit-only. This is not a new captures policy.
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,next:F.Frame<S,C,R,E,P,Q,identity,project> -> A -> List<&2,Out> -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),frame:F.Frame<S,C,R,E,P,Q,identity,project>,state:A,values:List<&2,Out>,result:T.Outcome<Query.Error<U>>) -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match result:
    case T.Failure{error}:(frame,(state,(T.Failure{error},[])))
    case T.Success{}:next(frame,state,values)

def returned(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,next:F.Frame<S,C,R,E,P,Q,identity,project> -> A -> List<&2,Out> -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),values:List<&2,Out>,observed:F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<U> & Out))) -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match observed:
    case (F.Frame{owner,handle,+error,cursor,receipts,pending},(state,(outcome,value))):completed(~S,~C,~R,~E,~P,~Q,~A,~U,~Out,~Ops,~identity,~project,next,F.Frame{owner,handle,error,cursor,receipts,pending},state,value <> values,Query.outcome(~U,error,outcome))

def selected(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~grants:Ops(F.Frame<S,C,R,E,P,Q,identity,project>),~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (A & (T.Outcome<U> & Out)),next:F.Frame<S,C,R,E,P,Q,identity,project> -> A -> List<&2,Out> -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)),state:A,values:List<&2,Out>,observed:F.Frame<S,C,R,E,P,Q,identity,project> & Bool) -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match observed:
    case (frame,False{}):next(frame,state,values)
    case (frame,True{}):returned(~S,~C,~R,~E,~P,~Q,~A,~U,~Out,~Ops,~identity,~project,next,values,Cap.invoke_owned(~Ops,~A,~(A & (T.Outcome<U> & Out)),~body,~F.Frame<S,C,R,E,P,Q,identity,project>,~grants,state,frame))

def at_handle(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:F.Frame<S,C,R,E,P,Q,identity,project>,handle:World.Handle<S>,cursor:U32) -> F.Frame<S,C,R,E,P,Q,identity,project>:
  match frame:
    case F.Frame{owner,_,_,_,receipts,pending}:F.Frame{owner,handle,None{},cursor,receipts,pending}

def run_rows(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Q:Type,~A:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~selector:F.Frame<S,C,R,E,P,Q,identity,project> -> F.Frame<S,C,R,E,P,Q,identity,project> & Bool,~grants:Ops(F.Frame<S,C,R,E,P,Q,identity,project>),~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (A & (T.Outcome<U> & Out)),handles:List<&2,World.Handle<S>>,+cursor:U32,frame:F.Frame<S,C,R,E,P,Q,identity,project>,state:A,values:List<&2,Out>) -> F.Frame<S,C,R,E,P,Q,identity,project> & (A & (T.Outcome<Query.Error<U>> & List<&2,Out>)):
  match handles:
    case []:(frame,(state,(T.Success{},List.reverse(&2,Out,values))))
    case handle <> rest:selected(~S,~C,~R,~E,~P,~Q,~A,~U,~Out,~Ops,~identity,~project,~grants,~body,(frame => state => values => run_rows(~S,~C,~R,~E,~P,~Q,~A,~U,~Out,~Ops,~identity,~project,~selector,~grants,~body,rest,cursor,frame,state,values)),state,values,selector(at_handle(~S,~C,~R,~E,~P,~Q,~identity,~project,frame,handle,cursor)))
