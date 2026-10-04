import Base
import ./types.bend as T
import ./runtime.bend as R

def runtime_created(result: R.Factory & Maybe<R.World>) -> R.World:
  match result:
    case (_,Some{world}): world
    case (_,None{}): R.World{0,0,[],[]}
def runtime_empty() -> R.World:
  runtime_created(R.create(8,R.Factory{0}))
def runtime_pending() -> R.World:
  R.tick([R.Reserve{1},R.Reserve{2},R.Reserve{3}],8,runtime_empty())
def runtime_live() -> R.World:
  R.flush(runtime_pending())
def runtime_mixed() -> R.World:
  R.flush(R.publish(runtime_live(),R.Handle{0,2},T.Insert{}))
def runtime_queued() -> R.World:
  R.publish(R.publish(runtime_mixed(),R.Handle{0,1},T.Insert{}),R.Handle{0,1},T.Remove{})
