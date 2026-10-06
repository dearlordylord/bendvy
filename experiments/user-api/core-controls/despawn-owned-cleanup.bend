import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/commands.bend as Cmd

def World() -> Type:
  W.World<S.Schema,S.Store,F32,S.SimEvent>
# Trusted storage inspection restores the exact temporarily moved owner.
# This bypasses liveness intentionally to detect hidden residual components.
def restored(~Owner: Type,+present: U32,result: Col.SwapOutcome<S.Schema,Owner>) -> Col.Column<S.Schema,Owner> & U32:
  match result:
    case Col.Accepted{column,_}: (column,present)
    case Col.Rejected{column,_}: (column,99)
def taken(~Owner: Type,+id: U32,result: Col.SwapOutcome<S.Schema,Owner>) -> Col.Column<S.Schema,Owner> & U32:
  match result:
    case Col.Accepted{column,None{}}: (column,0)
    case Col.Accepted{column,Some{owner}}: restored(~Owner,1,Col.swap(~S.Schema,~Owner,column,id,Some{owner}))
    case Col.Rejected{column,_}: (column,99)
def presence(~Owner: Type,column: Col.Column<S.Schema,Owner>,+id: U32) -> Col.Column<S.Schema,Owner> & U32:
  taken(~Owner,id,Col.swap(~S.Schema,~Owner,column,id,None{}))
def joined(positions: Col.Column<S.Schema,S.Position> & U32,velocities: Col.Column<S.Schema,S.Velocity> & U32,healths: Col.Column<S.Schema,S.Health> & U32,armors: Col.Column<S.Schema,S.Armor> & U32,tags: Col.Column<S.Schema,S.Tag> & U32) -> S.Store & List<&2,U32>:
  (positions,+p) = positions
  (velocities,+v) = velocities
  (healths,+h) = healths
  (armors,+a) = armors
  (tags,+t) = tags
  (S.Store{positions,velocities,healths,armors,tags},[p,v,h,a,t])
def inspect(+id: U32,store: S.Store) -> S.Store & List<&2,U32>:
  match store:
    case S.Store{positions,velocities,healths,armors,tags}: joined(presence(~S.Position,positions,id),presence(~S.Velocity,velocities,id),presence(~S.Health,healths,id),presence(~S.Armor,armors,id),presence(~S.Tag,tags,id))
def inspected(world: World(),handle: W.Handle<S.Schema>) -> World() & List<&2,U32>:
  match handle:
    case W.Handle{_,+id}: W.with_store(~S.Schema,~S.Store,~F32,~S.SimEvent,~List<&2,U32>,(store => inspect(id,store)),world)
def finished(result: T.Returned<World(),Unit>) -> World():
  match result:
    case T.Returned{world,_}: W.barrier(~S.Schema,~S.Store,~F32,~S.SimEvent,world)
def commit(tx: T.Tx<World(),S.SimEvent>) -> World():
  finished(Cmd.tx_finish(~S.Schema,~S.Store,~F32,~S.SimEvent,~Unit,tx,T.Success{}))
def after_cleanup(result: World() & List<&2,U32>) -> List<&2,U32>:
  (world,counts) = result
  counts
def cleanup_committed(+handle: W.Handle<S.Schema>,result: T.Tx<World(),S.SimEvent> & W.Status) -> List<&2,U32>:
  match result:
    case (tx,W.Accepted{}): after_cleanup(inspected(commit(tx),handle))
    case (tx,_): [99]
def before_cleanup(+handle: W.Handle<S.Schema>,result: World() & List<&2,U32>) -> List<&2,U32>:
  match result:
    case (world,[1,1,1,1,1]): cleanup_committed(handle,Cmd.tx_despawn_with(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.clear,T.begin(~World(),~S.SimEvent,world),handle))
    case _: [98]
def spawned(result: T.Tx<World(),S.SimEvent> & W.Reservation<S.Schema>) -> List<&2,U32>:
  match result:
    case (tx,W.Reserved{+handle}): before_cleanup(handle,inspected(commit(tx),handle))
    case _: [97]
def created(result: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> List<&2,U32>:
  match result:
    case W.Created{factory,world}: spawned(Cmd.tx_spawn(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.Bundle,~S.populate,T.begin(~World(),~S.SimEvent,world),S.actor_a()))
    case _: [96]
def main() -> List<&2,U32>:
  created(S.create(W.factory(),1.0))
