import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-resource-declaration.bend as D
def component_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~query:O.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,V>,~render:V -> String,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,V>>>>:
  DTO.append_previous(~S,~C,~R,~E,~Unit,~Ops,~V,~query,~render,(world,DTO.Observation{Unit{},[]}))
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & DTO.Observation<V>:
  match result:
    case (world,+value):(world,DTO.Observation{value,[D.name(~S,~C,~R,~E,~Ops,~V,declaration) ++ "=" ++ D.presenter(~S,~C,~R,~E,~Ops,~V,declaration)(value)]})
def resource_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<V>:
  resource_returned(~S,~C,~R,~E,~Ops,~V,~declaration,D.observer(~S,~C,~R,~E,~Ops,~V,declaration)(world))
