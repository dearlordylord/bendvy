import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/transaction.bend as T
import commands.bend as Cmd
import compose.bend as Q
import capabilities.bend as Cap

# Trusted declaration; gameplay can only thread universally quantified H.
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type,-H:Type> is Type:
  Plan{caps:Ops(H),select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,enter:Q.Frame<S,Store,R,E> -> H,leave:H -> Q.Frame<S,Store,R,E>}

def plan_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,plan:Plan<S,Store,R,E,Ops,H>) -> Ops(H):
  match plan:
    case Plan{caps,_,_,_}: caps

def plan_select(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,plan:Plan<S,Store,R,E,Ops,H>) -> Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool:
  match plan:
    case Plan{_,select,_,_}: select

def plan_enter(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,plan:Plan<S,Store,R,E,Ops,H>) -> Q.Frame<S,Store,R,E> -> H:
  match plan:
    case Plan{_,_,enter,_}: enter

def plan_leave(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,plan:Plan<S,Store,R,E,Ops,H>) -> H -> Q.Frame<S,Store,R,E>:
  match plan:
    case Plan{_,_,_,leave}: leave

def left(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~U:Data,~Out:Data,~leave:H -> Q.Frame<S,Store,R,E>,observed:H & (T.Outcome<U> & Out)) -> Q.Frame<S,Store,R,E> & (T.Outcome<U> & Out):
  match observed:
    case (owner,result): (leave(owner),result)

def prepend(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,value: Out,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  (tx,result) = observed
  (outcome,values) = result
  (tx,(outcome,value <> values))
def completed(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>),tx: T.Tx<W.World<S,Store,R,E>,E>,value: Out,result: T.Outcome<Q.Error<U>>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match result:
    case T.Success{}: prepend(~S,~Store,~R,~E,~U,~Out,value,next(tx))
    case T.Failure{error}: (tx,(T.Failure{error},[]))
def body_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>),observed: Q.Frame<S,Store,R,E> & (T.Outcome<U> & Out)) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match observed:
    case (Q.Frame{tx,_,internal,_},(user,value)): completed(~S,~Store,~R,~E,~U,~Out,next,tx,value,Q.outcome(~U,internal,user))
def selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops,H>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>),observed: Q.Frame<S,Store,R,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match observed:
    case (Q.Frame{tx,_,_,_},False{}): next(tx)
    case (frame,True{}): body_returned(~S,~Store,~R,~E,~U,~Out,next,left(~S,~Store,~R,~E,~H,~U,~Out,~plan_leave(~S,~Store,~R,~E,~Ops,~H,plan),Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~H,~plan_caps(~S,~Store,~R,~E,~Ops,~H,plan),args,plan_enter(~S,~Store,~R,~E,~Ops,~H,plan)(frame))))
def run_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops,H>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles: List<&2,W.Handle<S>>,+args: A,+cursor: U32,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match handles:
    case []: (tx,(T.Success{},[]))
    case handle <> rest: selected(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,args,(tx => run_handles(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,rest,args,cursor,tx)),plan_select(~S,~Store,~R,~E,~Ops,~H,plan)(Q.Frame{tx,handle,None{},cursor}))
def finish_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,values: List<&2,Out>,returned: T.Returned<W.World<S,Store,R,E>,Q.Error<U>>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match returned:
    case T.Returned{world,T.Success{}}: Q.Executed{world,T.Success{},values}
    case T.Returned{world,T.Failure{error}}: Q.Executed{world,T.Failure{error},[]}
def finished(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match observed:
    case (tx,(result,values)): finish_returned(~S,~Store,~R,~E,~U,~Out,values,Cmd.tx_finish(~S,~Store,~R,~E,~Q.Error<U>,tx,result))
def reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops,H>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: U32,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  (world,handles) = observed
  finished(~S,~Store,~R,~E,~U,~Out,run_handles(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,handles,args,cursor,T.begin(~W.World<S,Store,R,E>,~E,world)))
# Snapshot live handles in ascending order; deferred commands stay invisible.
def each(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops,H>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,args,0,W.handles(~S,~Store,~R,~E,world))


# Preserve explicit reader cursor in the accepted row frame.
def each_since(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops,H>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,cursor: U32) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,args,cursor,W.handles(~S,~Store,~R,~E,world))

# Separate closed template fields avoid constructing runtime Plan for projections.
def selected_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>),observed: Q.Frame<S,Store,R,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match observed:
    case (Q.Frame{tx,_,_,_},False{}): next(tx)
    case (frame,True{}): body_returned(~S,~Store,~R,~E,~U,~Out,next,left(~S,~Store,~R,~E,~H,~U,~Out,~leave,Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~H,~caps,args,enter(frame))))
def run_handles_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles: List<&2,W.Handle<S>>,+args: A,+cursor: U32,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match handles:
    case []: (tx,(T.Success{},[]))
    case handle <> rest: selected_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,args,(tx => run_handles_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,rest,args,cursor,tx)),select(Q.Frame{tx,handle,None{},cursor}))
def reserved_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: U32,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  (world,handles) = observed
  finished(~S,~Store,~R,~E,~U,~Out,run_handles_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,handles,args,cursor,T.begin(~W.World<S,Store,R,E>,~E,world)))
# Snapshot live handles in ascending order; deferred commands stay invisible.
def each_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  reserved_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,args,0,W.handles(~S,~Store,~R,~E,world))


# Preserve explicit reader cursor in the accepted row frame.
def each_fields_since(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~H: Type,~A: Data,~U: Data,~Out: Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,cursor: U32) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  reserved_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,args,cursor,W.handles(~S,~Store,~R,~E,world))
