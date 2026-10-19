import Base
import ./recognized-query-declaration.bend as N
import ./internal/compact-operational-frame.bend as F
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-system.bend as Ordinary
import ./compose.bend as Q
import ./transaction.bend as T
import ./world.bend as W
import ./system.bend as Sys
import ./capabilities.bend as Cap

# Registry ownership and final transaction semantics remain ordinary. The closed
# recognized carrier supplies operations for this concrete, smaller owner.
def target(~S:Data,~Store:Type,~R:Type,~E:Data,handle:W.Handle<S>,frame:F.Frame<S,Store,R,E>) -> F.Frame<S,Store,R,E>:
  match frame:
    case F.Frame{namespace,allocator,store,_,_,cursor,shell}:F.Frame{namespace,allocator,store,handle,None{},cursor,shell}
def row_completed(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,frame:F.Frame<S,Store,R,E>,value:Out,status:T.Outcome<Q.Error<U>>) -> F.Frame<S,Store,R,E> & Q.RowResult<U,Out>:
  match status:
    case T.Success{}:(frame,Q.Passed{value})
    case T.Failure{error}:(frame,Q.Failed{error})
def body_returned(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,observed:F.Frame<S,Store,R,E> & (T.Outcome<U> & Out)) -> F.Frame<S,Store,R,E> & Q.RowResult<U,Out>:
  match observed:
    case (F.Frame{namespace,allocator,store,handle,+error,cursor,shell},(user,value)):row_completed(~S,~Store,~R,~E,~U,~Out,F.Frame{namespace,allocator,store,handle,error,cursor,shell},value,Q.outcome(~U,error,user))
def selected(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args:A,observed:F.Frame<S,Store,R,E> & Bool) -> F.Frame<S,Store,R,E> & Q.RowResult<U,Out>:
  match observed:
    case (frame,False{}):(frame,Q.Skipped{})
    case (frame,True{}):body_returned(~S,~Store,~R,~E,~U,~Out,Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~F.Frame<S,Store,R,E>,~N.caps(~S,~Store,~R,~E,~Ops,query),args,frame))
def run_handles(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles:List<&2,W.Handle<S>>,+args:A,values:List<&2,Out>,observed:F.Frame<S,Store,R,E> & Q.RowResult<U,Out>) -> F.Frame<S,Store,R,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>):
  match handles observed:
    case _ Tuple{frame,Q.Failed{error}}:(frame,(T.Failure{error},List.reverse(&2,Out,values)))
    case Nil{} Tuple{frame,Q.Skipped{}}:(frame,(T.Success{},List.reverse(&2,Out,values)))
    case Nil{} Tuple{frame,Q.Passed{value}}:(frame,(T.Success{},List.reverse(&2,Out,value <> values)))
    case Con{handle,rest} Tuple{frame,Q.Skipped{}}:run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,rest,args,values,selected(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,args,N.selector(~S,~Store,~R,~E,~Ops,query)(target(~S,~Store,~R,~E,handle,frame))))
    case Con{handle,rest} Tuple{frame,Q.Passed{value}}:run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,rest,args,value <> values,selected(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,args,N.selector(~S,~Store,~R,~E,~Ops,query)(target(~S,~Store,~R,~E,handle,frame))))
def finish_frame(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,result:T.Outcome<Q.Error<U>> & List<&2,Out>,frame:Q.Frame<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match frame:
    case Q.Frame{tx,_,_,_}:Q.finished(~S,~Store,~R,~E,~U,~Out,(tx,result))
def finished(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,observed:F.Frame<S,Store,R,E> & (T.Outcome<Q.Error<U>> & List<&2,Out>)) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match observed:
    case (frame,result):finish_frame(~S,~Store,~R,~E,~U,~Out,result,F.restore(~S,~Store,~R,~E,frame))
def reserved(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),+args:A,cursor:U32,observed:W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  match observed:
    case (world,[]):Q.finished(~S,~Store,~R,~E,~U,~Out,(T.begin(~W.World<S,Store,R,E>,~E,world),(T.Success{},[])))
    case (world,+handle <> rest):finished(~S,~Store,~R,~E,~U,~Out,run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,rest,args,[],selected(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,args,N.selector(~S,~Store,~R,~E,~Ops,query)(F.extract(~S,~Store,~R,~E,Q.Frame{T.begin(~W.World<S,Store,R,E>,~E,world),handle,None{},cursor})))))
def runner(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,Store,R,E>,args:A & U32) -> Sys.Outcome<W.World<S,Store,R,E>,Q.Error<U>,List<&2,Out>>:
  match args:
    case (args,cursor):Ordinary.completed(~S,~Store,~R,~E,~U,~Out,reserved(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,args,cursor,W.handles(~S,~Store,~R,~E,world)))
def registered(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),slot:String,clauses:List<&2,Decl.Clause<S>>,result:Sys.RegistrationResult<S,Store,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body)>) -> Ordinary.Defined<S,W.World<S,Store,R,E>,Sys.Registry<S,Store,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  match result:
    case Sys.RegistrationFailed{world}:Ordinary.Rejected{world}
    case Sys.Registered{world,registry}:Ordinary.Defined{world,Ordinary.Owner{registry,slot,clauses}}
def define(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:N.Declaration<S,Store,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),world:W.World<S,Store,R,E>,name:String,slot:String) -> Ordinary.Defined<S,W.World<S,Store,R,E>,Sys.Registry<S,Store,R,E,A & U32,Q.Error<U>,List<&2,Out>,runner(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>:
  registered(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body,slot,Decl.clauses(~S,~Q.Frame<S,Store,R,E>,~Ops(Q.Frame<S,Store,R,E>),N.ordinary(~S,~Store,~R,~E,~Ops,query)),Sys.register(~S,~Store,~R,~E,~(A & U32),~Q.Error<U>,~List<&2,Out>,~runner(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~query,~body),world,name,Ordinary.access(~S,Decl.clauses(~S,~Q.Frame<S,Store,R,E>,~Ops(Q.Frame<S,Store,R,E>),N.ordinary(~S,~Store,~R,~E,~Ops,query)))))
