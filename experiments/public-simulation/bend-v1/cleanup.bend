import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ./storage.bend as Storage

# Deferred despawn clears every owned family, including velocity, rather than
# merely hiding a live row. Removed arbitrary Type payloads are released here.
def cleared(~S: Data,result: Col.SwapOutcome<S,Array<U32>>) -> Col.Column<S,Array<U32>>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def clear(~S: Data,store: Storage.Store<S>,handle: W.Handle<S>) -> Storage.Store<S>:
  match store handle:
    case Storage.Store{position,velocity,health} W.Handle{_,+id}:
      Storage.Store{cleared(~S,Col.clear(~S,~Array<U32>,position,id)),cleared(~S,Col.clear(~S,~Array<U32>,velocity,id)),cleared(~S,Col.clear(~S,~Array<U32>,health,id))}
