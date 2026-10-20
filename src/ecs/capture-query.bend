import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./compose.bend as Q
import ./transaction.bend as T
import ./commands.bend as Cmd

# Ordinary query selection and access stay in Q.Frame. The affine accumulator is
# outside the transaction journal and survives each entered row, including error.
type Executed<World:Type,L:Type,Error:Data,Out:Data> is Type:
  Executed{world:World,capture:L,outcome:T.Outcome<Error>,values:List<&2,Out>}
def prepend(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,value:Out,observed:L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>))) -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)):
  match observed:
    case (capture,(tx,(status,values))):(capture,(tx,(status,value <> values)))
def completed(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,next:L -> T.Tx<W.World<S,C,R,E>,E> -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)),capture:L,tx:T.Tx<W.World<S,C,R,E>,E>,value:Out,status:T.Outcome<Q.Error<U>>) -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)):
  match status:
    case T.Success{}:prepend(~S,~C,~R,~E,~L,~U,~Out,value,next(capture,tx))
    case T.Failure{error}:(capture,(tx,(T.Failure{error},[])))
def body_returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,next:L -> T.Tx<W.World<S,C,R,E>,E> -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)),observed:Q.Frame<S,C,R,E> & (L & (T.Outcome<U> & Out))) -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)):
  match observed:
    case (Q.Frame{tx,_,internal,_},(capture,(user,value))):completed(~S,~C,~R,~E,~L,~U,~Out,next,capture,tx,value,Q.outcome(~U,internal,user))
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,capture:L,next:L -> T.Tx<W.World<S,C,R,E>,E> -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)),observed:Q.Frame<S,C,R,E> & Bool) -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)):
  match observed:
    case (Q.Frame{tx,_,_,_},False{}):next(capture,tx)
    case (frame,True{}):body_returned(~S,~C,~R,~E,~L,~U,~Out,next,body(Q.Frame<S,C,R,E>,Q.plan_caps(~S,~C,~R,~E,~Ops,plan),capture,args,frame))
def run_handles(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),handles:List<&2,W.Handle<S>>,+args:A,+cursor:Maybe<&2,Tick.Tick>,capture:L,tx:T.Tx<W.World<S,C,R,E>,E>) -> L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)):
  match handles:
    case []:(capture,(tx,(T.Success{},[])))
    case handle <> rest:selected(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,args,capture,local => transaction => run_handles(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,rest,args,cursor,local,transaction),Q.plan_select(~S,~C,~R,~E,~Ops,plan)(Q.Frame{tx,handle,None{},cursor}))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,capture:L,values:List<&2,Out>,result:T.Returned<W.World<S,C,R,E>,Q.Error<U>>) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  match result:
    case T.Returned{world,T.Success{}}:Executed{world,capture,T.Success{},values}
    case T.Returned{world,T.Failure{error}}:Executed{world,capture,T.Failure{error},[]}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,observed:L & (T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>))) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  match observed:
    case (capture,(tx,(status,values))):returned(~S,~C,~R,~E,~L,~U,~Out,capture,values,Cmd.tx_finish(~S,~C,~R,~E,~Q.Error<U>,tx,status))
def scope_finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,owned:Bool,result:Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  match result:
    case Executed{world,capture,outcome,values}:Executed{W.finish_run(~S,~C,~R,~E,owned,world),capture,outcome,values}
def reserved_inner(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,cursor:Maybe<&2,Tick.Tick>,capture:L,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  (world,handles) = result
  finished(~S,~C,~R,~E,~L,~U,~Out,run_handles(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,handles,args,cursor,capture,T.begin(~W.World<S,C,R,E>,~E,world)))
def reserved_scoped(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,cursor:Maybe<&2,Tick.Tick>,capture:L,handles:List<&2,W.Handle<S>>,admitted:W.World<S,C,R,E> & Bool) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  (world,owned)=admitted
  scope_finished(~S,~C,~R,~E,~L,~U,~Out,owned,reserved_inner(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,args,cursor,capture,(world,handles)))
def reserved(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,cursor:Maybe<&2,Tick.Tick>,capture:L,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  (world,handles)=result
  reserved_scoped(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,args,cursor,capture,handles,W.ensure_run(~S,~C,~R,~E,world))

def each_since(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,~Ops:Type -> Type,~A:Data,~plan:Q.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,cursor:Maybe<&2,Tick.Tick>,capture:L,world:W.World<S,C,R,E>) -> Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>:
  reserved(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan,~body,args,cursor,capture,W.handles(~S,~C,~R,~E,world))
