import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-resource-field-declaration.bend as D
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,result:W.World<S,C,R,E> & V) -> W.World<S,C,R,E> & DTO.Observation<V>:
  match result:
    case (world,+value):(world,DTO.Observation{value,[D.name(~S,~C,~R,~E,~Ops,~V,declaration) ++ "=" ++ D.presenter(~S,~C,~R,~E,~Ops,~V,declaration)(value)]})
def resource_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,~declaration:D.Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<V>:
  resource_returned(~S,~C,~R,~E,~Ops,~V,~declaration,D.observer(~S,~C,~R,~E,~Ops,~V,declaration)(world))
