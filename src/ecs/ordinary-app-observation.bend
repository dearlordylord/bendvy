import Base
import ./world.bend as W
import ./compose.bend as Q
import ./inspector.bend as I
import ./inspector-query.bend as IQ
import ./ordinary-query-observable.bend as O
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-resource-declaration.bend as D
import ./ordinary-resource-system.bend as P
import ./transaction.bend as T
def component_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~render:V -> String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>:
  DTO.append_previous(~S,~C,~R,~E,~Unit,~Ops,~V,~query,~render,(world,DTO.Observation{Unit{},[]}))
def resource_observed(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,name:String,render:V -> String,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & DTO.Observation<V>:
  match result:
    case (world,+value):(world,DTO.Observation{value,[name ++ "=" ++ render(value)]})
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & DTO.Observation<V>:
  resource_observed(~S,~C,~R,~E,~V,D.name(~S,~C,~R,~E,~Ops,~V,declaration),D.presenter(~S,~C,~R,~E,~Ops,~V,declaration),result)
def resource_declared(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:D.Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<V>:
  match declaration:
    case D.Declaration{ordinary,observe,render}:resource_observed(~S,~C,~R,~E,~V,D.named(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary)),render,observe(world))
def resource_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<V>:
  resource_declared(~S,~C,~R,~E,~Ops,~V,declaration,world)
