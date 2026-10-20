import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./compose.bend as Q
import ./capture-query.bend as Fold
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-system.bend as Ordinary
import ./ordinary-owned-event.bend as Pub
import ./owned-event-storage.bend as Storage
# Engine-private staged owner, outside the query transaction and its inverses.
# Ordinary gameplay sees independent abstract H (query) and J (publication).
type Stage<P:Type> is Type:Stage{newest:List<P>}
def emit(~P:Type,stage:Stage<P>,payload:P) -> Stage<P>:
  match stage:
    case Stage{newest}:Stage{payload <> newest}
def plan(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out))) -> Q.Plan<S,C,Storage.Resources<R,P>,Nat,Ops>:
  Q.Plan{Decl.grant(~S,~Q.Frame<S,C,Storage.Resources<R,P>,Nat>,~Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>),query),Decl.selector(~S,~Q.Frame<S,C,Storage.Resources<R,P>,Nat>,~Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>),query)}
def row(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out)),~H:Type,~caps:Ops(H),stage:Stage<P>,args:A,owner:H) -> H & (Stage<P> & (T.Outcome<U> & Out)):
  body(H,caps,Stage<P>,Pub.Write{emit(~P)},args,owner,stage)
def finished(~S:Data,~C:Type,~R:Type,~P:Type,~U:Data,~Out:Data,result:Fold.Executed<W.World<S,C,Storage.Resources<R,P>,Nat>,Stage<P>,Q.Error<U>,Out>) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>>:
  match result:
    case Fold.Executed{world,Stage{newest},T.Success{},values}:Sys.Succeeded{Storage.commit_owned(~S,~C,~R,~P,world,List.reverse(&1,P,newest)),Pub.Reply{T.Success{},values,[]}}
    case Fold.Executed{world,Stage{newest},T.Failure{error},_}:Sys.Succeeded{world,Pub.Reply{T.Failure{error},[],List.reverse(&1,P,newest)}}
def runner(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out)),world:W.World<S,C,Storage.Resources<R,P>,Nat>,input:A & Maybe<&2,Tick.Tick>) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>>:
  match input:
    case (args,cursor):finished(~S,~C,~R,~P,~U,~Out,Fold.each_since(~S,~C,~Storage.Resources<R,P>,~Nat,~Stage<P>,~U,~Out,~Ops,~A,~plan(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body),~row(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body),args,cursor,Stage{[]},world))
def Registry(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out))) -> Type:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)>
def define(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out)),world:W.World<S,C,Storage.Resources<R,P>,Nat>,name:String) -> Sys.RegistrationResult<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)>:
  Sys.register(~S,~C,~Storage.Resources<R,P>,~Nat,~(A & Maybe<&2,Tick.Tick>),~Unit,~Pub.Reply<Q.Error<U>,List<&2,Out>,P>,~runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body),world,name,List.append(&2,String,Ordinary.access(~S,Decl.clauses(~S,~Q.Frame<S,C,Storage.Resources<R,P>,Nat>,~Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>),query)),[Pub.access(~S,~P,identity,":write")]))
# Transport is closed and always succeeds. Semantic failure must not advance the
# ordinary query cursor; the returned receipt remains outside Sys.Failed erasure.
def run_observed(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out)),world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:A,observed:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)> & Maybe<&2,Tick.Tick>) -> Sys.RunResult<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)>:
  match observed:
    case (registry,cursor):Sys.run(~S,~C,~Storage.Resources<R,P>,~Nat,~(A & Maybe<&2,Tick.Tick>),~Unit,~Pub.Reply<Q.Error<U>,List<&2,Out>,P>,~runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body),registry,world,(args,cursor))
def run(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Pub.Domain<S,P>,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,Storage.Resources<R,P>,Nat>,Ops(Q.Frame<S,C,Storage.Resources<R,P>,Nat>)>,~body:@-H:Type -> @-caps:Ops(H) -> @-J:Type -> @-emit:Pub.Write<S,P,identity,J> -> A -> H -> J -> H & (J & (T.Outcome<U> & Out)),registry:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)>,world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:A) -> Sys.RunResult<S,C,Storage.Resources<R,P>,Nat,A & Maybe<&2,Tick.Tick>,Unit,Pub.Reply<Q.Error<U>,List<&2,Out>,P>,runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body)>:
  run_observed(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body,world,args,Sys.cursor(~S,~C,~Storage.Resources<R,P>,~Nat,~(A & Maybe<&2,Tick.Tick>),~Unit,~Pub.Reply<Q.Error<U>,List<&2,Out>,P>,~runner(~S,~C,~R,~P,~identity,~Ops,~A,~U,~Out,~query,~body),registry))
