import Base
import ./world.bend as W
import ./compose.bend as Q
import ./capture-query.bend as Fold
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-system.bend as Ordinary
import ./local.bend as Local
import ./captures.bend as Capture
import ./transaction.bend as T
# Capture lifecycle reuses Local; query visibility has its own success-only cursor.
# Advanced lowering of the closed query declaration into its typed grant
# and membership predicate; it performs no traversal or capture mutation.
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out))) -> Q.Plan<S,C,R,E,Ops>:
  Q.Plan{Decl.grant(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Decl.selector(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query)}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,result:Fold.Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>) -> Local.Outcome<W.World<S,C,R,E>,L,Q.Error<U>,List<&2,Out>>:
  match result:
    case Fold.Executed{world,capture,T.Success{},values}:Local.Succeeded{world,capture,values}
    case Fold.Executed{world,capture,T.Failure{error},_}:Local.Failed{world,capture,error}
# Advanced captured-query runner with explicit (args,cursor). Threads L
# through selected rows while the ECS transaction journals World changes.
# Failure retains returned capture but discards row outputs. Bypasses runtime
# registration checks; ordinary callers use define/run or App capture add.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),world:W.World<S,C,R,E>,capture:L,args:A & U32) -> Local.Outcome<W.World<S,C,R,E>,L,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):finished(~S,~C,~R,~E,~L,~U,~Out,Fold.each_since(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),~body,args,cursor,capture,world))
# Runtime-bound captured-query owner: a Local instance owns affine capture L
# and a separate cursor tracks query lifecycle visibility. Keep both returned
# parts together across runs; raw constructors are trusted administration.
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Ops:Type -> Type,-A:Data,-U:Data,-Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out))> is Type:
  Owner{instance:Local.Instance<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>,cursor:U32}
# Registered returns World and captured-query owner; Rejected returns
# World and initial capture L without invoking the query body.
type Registration<World:Type,Owned:Type,L:Type> is Type:
  Registered{world:World,owner:Owned}
  Rejected{world:World,capture:L}
# Completed returns World, retained capture owner and ordered row outputs
# or query error. Refused returns World/owner and original Data args before
# body execution. Capture state survives body failure; failed row outputs do not.
type Run<World:Type,Owned:Type,A:Data,Error:Data,Out:Data> is Type:
  Completed{world:World,owner:Owned,result:Result<Error,List<&2,Out>>}
  Refused{world:World,owner:Owned,args:A}
# Removed returns World and detached affine capture after deregistration.
# RemovalRejected returns World and original owner. No finalizer is invoked
# here: caller decides how to reuse or dispose the returned capture.
type Removal<World:Type,Owned:Type,L:Type> is Type:
  Removed{world:World,capture:L}
  RemovalRejected{world:World,owner:Owned}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),result:Local.Registered<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match result:
    case Local.Registered{world,instance}:Registered{world,Owner{instance,0}}
    case Local.RegistrationRejected{world,capture}:Rejected{world,capture}
# Register a captured query with access derived from the same declaration.
# Consumes capture; refusal returns it with World. Success owns a real Local
# registration and initializes a query cursor at zero. No body runs at setup.
# Example: examples/captured-query/app.bend.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),world:W.World<S,C,R,E>,name:String,capture:L) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  registered(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,Capture.register(~S,~C,~R,~E,~L,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),world,name,Ordinary.access(~S,Decl.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query)),capture))
def successful(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),instance:Local.Instance<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>,values:List<&2,Out>,clocked:W.World<S,C,R,E> & U32) -> Run<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,A,Q.Error<U>,Out>:
  (world,clock) = clocked
  Completed{world,Owner{instance,clock},Done{values}}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),cursor:U32,result:Local.Run<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>) -> Run<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,A,Q.Error<U>,Out>:
  match result:
    case Local.Completed{world,instance,Done{values}}:successful(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,instance,values,W.clock(~S,~C,~R,~E,world))
    case Local.Completed{world,instance,Fail{error}}:Completed{world,Owner{instance,cursor},Fail{error}}
    case Local.Refused{world,instance,(args,_)}:Refused{world,Owner{instance,cursor},args}
# Execute the checked captured-query registration at its retained cursor.
# Success advances cursor to resulting World clock; error/refusal preserves it.
# Query failure rolls back recorded World changes but retains capture changes;
# registration refusal returns original args without running body. Deferred
# commands remain invisible until explicit barriers.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>,args:A) -> Run<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,A,Q.Error<U>,Out>:
  match owner:
    case Owner{instance,+cursor}:returned(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,cursor,Capture.run(~S,~C,~R,~E,~L,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),instance,world,(args,cursor)))
# No callback entry: preserve capture and the existing query reader cursor.
# Return the same captured owner and World without invoking the body.
# Both capture state and query cursor remain unchanged.
def skip(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>) -> Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & W.World<S,C,R,E>:
  (owner,world)
def removed(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),cursor:U32,result:Local.Disposal<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),L>) -> Removal<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match result:
    case Local.Disposed{world,capture}:Removed{world,capture}
    case Local.DisposalRejected{world,instance}:RemovalRejected{world,Owner{instance,cursor}}
# Remove the matching registration and return its actual affine capture.
# Refusal returns the original owner for retry; success returns Removed with
# World/capture. Does not invoke a user finalizer or reset unrelated systems.
def unregister(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>) -> Removal<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match owner:
    case Owner{instance,cursor}:removed(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,cursor,Capture.unregister(~S,~C,~R,~E,~L,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),instance,world))
