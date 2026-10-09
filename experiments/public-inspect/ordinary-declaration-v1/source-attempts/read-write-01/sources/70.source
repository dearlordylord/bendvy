import Base
import world.bend as W
import compose.bend as Q
import owned-compose.bend as O
import optimized-compose.bend as Opt
import transaction.bend as T

def each(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,~A:Data,~U:Data,~Out:Data,~plan:O.Plan<S,Store,R,E,Ops,H>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  Opt.recovered(~S,~Store,~R,~E,~U,~Out,~recover,O.each(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,args,Opt.map_store(~S,~Store,~R,~E,~prepare,world)))
def each_since(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,~A:Data,~U:Data,~Out:Data,~plan:O.Plan<S,Store,R,E,Ops,H>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>,cursor:U32) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  Opt.recovered(~S,~Store,~R,~E,~U,~Out,~recover,O.each_since(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~plan,~body,args,Opt.map_store(~S,~Store,~R,~E,~prepare,world),cursor))

def each_fields(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,~A:Data,~U:Data,~Out:Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  Opt.recovered(~S,~Store,~R,~E,~U,~Out,~recover,O.each_fields(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,args,Opt.map_store(~S,~Store,~R,~E,~prepare,world)))
def each_fields_since(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~H:Type,~A:Data,~U:Data,~Out:Data,~caps:Ops(H),~select:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & Bool,~enter:Q.Frame<S,Store,R,E> -> H,~leave:H -> Q.Frame<S,Store,R,E>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~prepare:Store -> Store,~recover:Store -> Store,args:A,world:W.World<S,Store,R,E>,cursor:U32) -> Q.Executed<W.World<S,Store,R,E>,Q.Error<U>,Out>:
  Opt.recovered(~S,~Store,~R,~E,~U,~Out,~recover,O.each_fields_since(~S,~Store,~R,~E,~Ops,~H,~A,~U,~Out,~caps,~select,~enter,~leave,~body,args,Opt.map_store(~S,~Store,~R,~E,~prepare,world),cursor))
