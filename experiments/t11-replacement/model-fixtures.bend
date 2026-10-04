import Base
import ./types.bend as T
import ./model.bend as M

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
