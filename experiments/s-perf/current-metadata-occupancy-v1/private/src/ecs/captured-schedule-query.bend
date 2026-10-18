import Base
import ./world.bend as W
import ./local.bend as Local
import ./transaction.bend as T
import ./compose.bend as Q
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-capture-query.bend as O
import ./captured-schedule-composition.bend as Comp
type Leaf<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Ops:Type -> Type,-A:Data,-U:Data,-Out:Data,-query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out))> is Type:
  Leaf{owner:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,args:A,enabled:Bool}
def bind(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,args:A,enabled:Bool) -> Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>:
  Leaf{owner,args,enabled}
def catalog(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),leaf:Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>) -> Leaf<S,C,R,E,L,Ops,A,U,Out,query,body> & List<&2,Comp.Identity>:
  match leaf:
    case Leaf{O.Owner{Local.Instance{+ns,+id,+name,+access,capture},cursor},args,enabled}:(Leaf{O.Owner{Local.Instance{ns,id,name,access,capture},cursor},args,enabled},[Comp.Identity{ns,id,name,access}])
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,enabled:Bool,result:O.Run<W.World<S,C,R,E>,O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,A,Q.Error<U>,Out>) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,Q.Error<U>>:
  match result:
    case O.Completed{world,owner,Done{_}}:Comp.Completed{world,Leaf{owner,args,enabled}}
    case O.Completed{world,owner,Fail{error}}:Comp.Failed{world,Leaf{owner,args,enabled},error}
    case O.Refused{world,owner,_}:Comp.Refused{world,Leaf{owner,args,enabled}}
def skipped(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),args:A,result:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & W.World<S,C,R,E>) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,Q.Error<U>>:
  match result:
    case (owner,world):Comp.Skipped{world,Leaf{owner,args,False{}}}
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),allowed:Bool,leaf:Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,Q.Error<U>>:
  match allowed leaf:
    case False{}, leaf:Comp.Refused{world,leaf}
    case True{}, Leaf{owner,args,False{}}:skipped(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,args,O.skip(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,owner,world))
    case True{}, Leaf{owner,+args,True{}}:returned(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,args,True{},O.run(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,owner,world,args))
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),leaf:Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,world:W.World<S,C,R,E>,id:U32) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Ops,A,U,Out,query,body>,Q.Error<U>>:
  match leaf:
    case Leaf{O.Owner{Local.Instance{ns,+actual,name,access,capture},cursor},args,enabled}:selected(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,U32.is_eq(actual,id),Leaf{O.Owner{Local.Instance{ns,actual,name,access,capture},cursor},args,enabled},world)
