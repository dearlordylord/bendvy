import Base
import compose.bend as Q
import capabilities.bend as Cap
import world.bend as W
import transaction.bend as T

type Error<U: Data> is Data:
  MissingEntity{entityId: U32}
  QueryMismatch{entityId: U32}
  NoEntities{}
  MultipleEntities{count: U32}
  BodyError{error: Q.Error<U>}
type Scanned<-S: Data,-Store: Type,-R: Type,-E: Data> is Type:
  Scanned{world: W.World<S,Store,R,E>,handles: List<&2,W.Handle<S>>}
type Executed<-World: Type,U: Data,Out: Data> is Type:
  Executed{world: World,result: Result<&2,&2,Error<U>,Out>}

def handle_id(~S: Data,handle: W.Handle<S>) -> U32:
  match handle:
    case W.Handle{_,id}: id
def add(~S: Data,selected: Bool,handle: W.Handle<S>,rest: List<&2,W.Handle<S>>) -> List<&2,W.Handle<S>>:
  match selected:
    case True{}: handle <> rest
    case False{}: rest
# Selection is a read-only observation even if a trusted plan accidentally mutates.
def unselect(~S: Data,~Store: Type,~R: Type,~E: Data,observed: Q.Frame<S,Store,R,E> & Bool) -> W.World<S,Store,R,E> & Bool:
  match observed:
    case (Q.Frame{T.Tx{world,undo,_,_},_,_,_},selected): (T.rollback(~W.World<S,Store,R,E>,undo,world),selected)
def prepend(~S: Data,~Store: Type,~R: Type,~E: Data,selected: Bool,handle: W.Handle<S>,observed: Scanned<S,Store,R,E>) -> Scanned<S,Store,R,E>:
  match observed:
    case Scanned{world,handles}: Scanned{world,add(~S,selected,handle,handles)}
def scanned_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,+cursor: U32,handle: W.Handle<S>,next: W.World<S,Store,R,E> -> Scanned<S,Store,R,E>,observed: W.World<S,Store,R,E> & Bool) -> Scanned<S,Store,R,E>:
  (world,selected) = observed
  prepend(~S,~Store,~R,~E,selected,handle,next(world))
def scan_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,handles: List<&2,W.Handle<S>>,+cursor: U32,world: W.World<S,Store,R,E>) -> Scanned<S,Store,R,E>:
  match handles:
    case []: Scanned{world,[]}
    case +handle <> rest: scanned_join(~S,~Store,~R,~E,~Ops,~plan,cursor,handle,(world => scan_handles(~S,~Store,~R,~E,~Ops,~plan,rest,cursor,world)),unselect(~S,~Store,~R,~E,Q.plan_select(~S,~Store,~R,~E,~Ops,plan)(Q.Frame{T.begin(~W.World<S,Store,R,E>,~E,world),handle,None{},cursor})))
def scan_reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,cursor: U32,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Scanned<S,Store,R,E>:
  (world,handles) = observed
  scan_handles(~S,~Store,~R,~E,~Ops,~plan,handles,cursor,world)
def scan(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,world: W.World<S,Store,R,E>,cursor: U32) -> Scanned<S,Store,R,E>:
  scan_reserved(~S,~Store,~R,~E,~Ops,~plan,cursor,W.handles(~S,~Store,~R,~E,world))
def count_list(~S: Data,handles: List<&2,W.Handle<S>>,n: U32) -> U32:
  match handles:
    case []: n
    case _ <> rest: count_list(~S,rest,(n + 1 : U32))
def counted(~S: Data,~Store: Type,~R: Type,~E: Data,observed: Scanned<S,Store,R,E>) -> W.World<S,Store,R,E> & U32:
  match observed:
    case Scanned{world,handles}: (world,count_list(~S,handles,0))
def count(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,world: W.World<S,Store,R,E>,cursor: U32) -> W.World<S,Store,R,E> & U32:
  counted(~S,~Store,~R,~E,scan(~S,~Store,~R,~E,~Ops,~plan,world,cursor))
def executed(~World: Type,~U: Data,~Out: Data,+entityId: U32,observed: Q.Executed<World,Q.Error<U>,Out>) -> Executed<World,U,Out>:
  match observed:
    case Q.Executed{world,T.Failure{error},_}: Executed{world,Fail{BodyError{error}}}
    case Q.Executed{world,T.Success{},value <> []}: Executed{world,Done{value}}
    case Q.Executed{world,T.Success{},[]}: Executed{world,Fail{QueryMismatch{entityId}}}
    case Q.Executed{world,T.Success{},_}: Executed{world,Fail{QueryMismatch{entityId}}}
def complete(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  (tx,(T.Success{},[]))
def invoke(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,cursor: U32) -> Executed<W.World<S,Store,R,E>,U,Out>:
  executed(~W.World<S,Store,R,E>,~U,~Out,handle_id(~S,handle),Q.finished(~S,~Store,~R,~E,~U,~Out,Q.body_returned(~S,~Store,~R,~E,~U,~Out,complete(~S,~Store,~R,~E,~U,~Out),Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~Q.Frame<S,Store,R,E>,~Q.plan_caps(~S,~Store,~R,~E,~Ops,plan),args,Q.Frame{T.begin(~W.World<S,Store,R,E>,~E,world),handle,None{},cursor}))))
def single_scanned(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: U32,observed: Scanned<S,Store,R,E>) -> Executed<W.World<S,Store,R,E>,U,Out>:
  match observed:
    case Scanned{world,[]}: Executed{world,Fail{NoEntities{}}}
    case Scanned{world,handle <> []}: invoke(~S,~Store,~R,~E,~Ops,~plan,~A,~U,~Out,~body,args,world,handle,cursor)
    case Scanned{world,+handles}: Executed{world,Fail{MultipleEntities{count_list(~S,handles,0)}}}
def single(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,+cursor: U32) -> Executed<W.World<S,Store,R,E>,U,Out>:
  single_scanned(~S,~Store,~R,~E,~Ops,~plan,~A,~U,~Out,~body,args,cursor,scan(~S,~Store,~R,~E,~Ops,~plan,world,cursor))
def lookup_selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,handle: W.Handle<S>,cursor: U32,observed: W.World<S,Store,R,E> & Bool) -> Executed<W.World<S,Store,R,E>,U,Out>:
  match observed:
    case (world,False{}): Executed{world,Fail{QueryMismatch{handle_id(~S,handle)}}}
    case (world,True{}): invoke(~S,~Store,~R,~E,~Ops,~plan,~A,~U,~Out,~body,args,world,handle,cursor)
def lookup_valid(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,+handle: W.Handle<S>,+cursor: U32,observed: W.World<S,Store,R,E> & Bool) -> Executed<W.World<S,Store,R,E>,U,Out>:
  match observed:
    case (world,False{}): Executed{world,Fail{MissingEntity{handle_id(~S,handle)}}}
    case (world,True{}): lookup_selected(~S,~Store,~R,~E,~Ops,~plan,~A,~U,~Out,~body,args,handle,cursor,unselect(~S,~Store,~R,~E,Q.plan_select(~S,~Store,~R,~E,~Ops,plan)(Q.Frame{T.begin(~W.World<S,Store,R,E>,~E,world),handle,None{},cursor})))
def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~plan: Q.Plan<S,Store,R,E,Ops>,~A: Data,~U: Data,~Out: Data,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,cursor: U32) -> Executed<W.World<S,Store,R,E>,U,Out>:
  lookup_valid(~S,~Store,~R,~E,~Ops,~plan,~A,~U,~Out,~body,args,handle,cursor,W.valid(~S,~Store,~R,~E,world,handle))
