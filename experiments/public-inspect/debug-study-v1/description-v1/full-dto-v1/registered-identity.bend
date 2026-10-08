import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
# Detached observation of an actual registered system owner. No name lookup,
# execution grant, cursor mutation, or reconstruction from guessed numeric IDs.
type Identity is Data:
  Identity{namespace:U32,id:U32}
def same(left:Identity,right:Identity) -> Bool:
  match left right:
    case Identity{ln,li} Identity{rn,ri}:Bool.and(U32.is_eq(ln,rn),U32.is_eq(li,ri))
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,C,R,E>->Args->Sys.Outcome<W.World<S,C,R,E>,Error,Output>,owner:Sys.Registry<S,C,R,E,Args,Error,Output,runner>) -> Sys.Registry<S,C,R,E,Args,Error,Output,runner> & Identity:
  match owner:
    case Sys.Registry{+namespace,+id,name,access,cursor}:(Sys.Registry{namespace,id,name,access,cursor},Identity{namespace,id})
