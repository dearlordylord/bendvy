import Base
import ./captures.bend as Captures
import ./local.bend as Local
import ./ordinary-app-local-fields.bend as Ord
import ./ordinary-resource-system.bend as P
import ./world.bend as W
import ./transaction.bend as T
# Ordinary authored body receives declared capabilities and its runtime capture.
# Registration metadata and transaction completion derive from the declaration.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),world:W.World<S,C,R,E>,name:String,local:L) -> Local.Registered<S,C,R,E,L,Args,Error,Out,Ord.runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>:
  Captures.register(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ord.runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body),world,name,P.access(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)),local)
