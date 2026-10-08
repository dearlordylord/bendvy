import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import ./decode.bend as Complete
import ./controls.bend as C

def duplicated(owner:C.Owner) -> D.Receipt<C.Owner> & D.Receipt<C.Owner>:
  (Complete.decode_owner(~C.Owner,~C.project,D.Integer{},owner),
   Complete.decode_owner(~C.Owner,~C.project,D.Integer{},owner))
