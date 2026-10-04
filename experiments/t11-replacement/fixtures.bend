import Base
import ./types.bend as T
import ./model.bend as M
import ./runtime.bend as R

# Reachable snapshots: actual factory/create, reserve, schedule and barrier calls.
def model_created(result: T.Creation) -> T.World:
  match result:
    case T.Created{_,world}: world
    case T.Full{_}: T.World{0n,0n,[],[]}
def empty() -> T.World:
  model_created(M.create(8n,T.Factory{0n}))
def pending() -> T.World:
  M.tick([T.Reserve{1n},T.Reserve{2n},T.Reserve{3n}],8n,empty())
def live() -> T.World:
  M.flush(pending())
def mixed() -> T.World:
  M.flush(M.publish(live(),T.Handle{0n,2n},T.Insert{}))
def queued() -> T.World:
  M.publish(M.publish(mixed(),T.Handle{0n,1n},T.Insert{}),T.Handle{0n,1n},T.Remove{})
def deleted() -> T.World:
  M.flush(M.publish(mixed(),T.Handle{0n,1n},T.Despawn{}))
def exhausted() -> T.World:
  M.tick([T.Reserve{7n},T.Reserve{8n}],2n,empty())
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
