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
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out))) -> Q.Plan<S,C,R,E,Ops>:
  Q.Plan{Decl.grant(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Decl.selector(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query)}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~U:Data,~Out:Data,result:Fold.Executed<W.World<S,C,R,E>,L,Q.Error<U>,Out>) -> Local.Outcome<W.World<S,C,R,E>,L,Q.Error<U>,List<&2,Out>>:
  match result:
    case Fold.Executed{world,capture,T.Success{},values}:Local.Succeeded{world,capture,values}
    case Fold.Executed{world,capture,T.Failure{error},_}:Local.Failed{world,capture,error}
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),world:W.World<S,C,R,E>,capture:L,args:A & U32) -> Local.Outcome<W.World<S,C,R,E>,L,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):finished(~S,~C,~R,~E,~L,~U,~Out,Fold.each_since(~S,~C,~R,~E,~L,~U,~Out,~Ops,~A,~plan(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),~body,args,cursor,capture,world))
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Ops:Type -> Type,-A:Data,-U:Data,-Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out))> is Type:
  Owner{instance:Local.Instance<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>,cursor:U32}
type Registration<World:Type,Owned:Type,L:Type> is Type:
  Registered{world:World,owner:Owned}
  Rejected{world:World,capture:L}
type Run<World:Type,Owned:Type,A:Data,Error:Data,Out:Data> is Type:
  Completed{world:World,owner:Owned,result:Result<Error,List<&2,Out>>}
  Refused{world:World,owner:Owned,args:A}
type Removal<World:Type,Owned:Type,L:Type> is Type:
  Removed{world:World,capture:L}
  RemovalRejected{world:World,owner:Owned}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),result:Local.Registered<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body)>) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match result:
    case Local.Registered{world,instance}:Registered{world,Owner{instance,0}}
    case Local.RegistrationRejected{world,capture}:Rejected{world,capture}
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
def run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>,args:A) -> Run<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,A,Q.Error<U>,Out>:
  match owner:
    case Owner{instance,+cursor}:returned(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,cursor,Capture.run(~S,~C,~R,~E,~L,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),instance,world,(args,cursor)))
# No callback entry: preserve capture and the existing query reader cursor.
def skip(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>) -> Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & W.World<S,C,R,E>:
  (owner,world)
def removed(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),cursor:U32,result:Local.Disposal<S,C,R,E,L,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),L>) -> Removal<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match result:
    case Local.Disposed{world,capture}:Removed{world,capture}
    case Local.DisposalRejected{world,instance}:RemovalRejected{world,Owner{instance,cursor}}
def unregister(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>) -> Removal<W.World<S,C,R,E>,Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>:
  match owner:
    case Owner{instance,cursor}:removed(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,cursor,Capture.unregister(~S,~C,~R,~E,~L,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body),instance,world))
