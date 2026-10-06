import Base
import schema.bend as S
import ../../src/ecs/world.bend as W
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/transaction.bend as T

def commit_result(result: T.Returned<S.World(),Unit>) -> S.World():
  match result:
    case T.Returned{world,_}: world
def commit(tx: S.Tx()) -> S.World():
  commit_result(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~Unit,~Unit,tx,T.Success{}))
def spawned(result: S.Tx() & W.Reservation<S.Schema>) -> S.Tx():
  (tx,_) = result
  tx
def spawn(tx: S.Tx(),bundle: S.Bundle) -> S.Tx():
  spawned(Cmd.tx_spawn(~S.Schema,~S.Store,~Unit,~Unit,~S.Bundle,~S.populate,tx,bundle))
def seed(world: S.World()) -> S.World():
  commit(spawn(spawn(spawn(spawn(spawn(spawn(T.begin(~S.World(),~Unit,world),S.seed_1()),S.seed_2()),S.seed_3()),S.seed_4()),S.seed_5()),S.seed_6()))
def handle(+namespace: U32,+id: U32) -> W.Handle<S.Schema>:
  W.Handle{namespace,id}
def insert_namespace(named: S.World() & U32) -> S.World():
  (world,+namespace) = named
  commit(S.queue_enabled(S.queue_recipe(T.begin(~S.World(),~Unit,world),handle(namespace,3),Some{S.recipe_payload(22)}),handle(namespace,5),Some{S.Enabled{}}))
def insert(world: S.World()) -> S.World():
  insert_namespace(W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def remove_namespace(named: S.World() & U32) -> S.World():
  (world,+namespace) = named
  commit(S.queue_recipe(S.queue_locked(T.begin(~S.World(),~Unit,world),handle(namespace,4),None{}),handle(namespace,1),None{}))
def remove(world: S.World()) -> S.World():
  remove_namespace(W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def despawn_join(observed: S.Tx() & W.Status) -> S.Tx():
  (tx,_) = observed
  tx
def churn_namespace(named: S.World() & U32) -> S.World():
  (world,+namespace) = named
  commit(S.queue_recipe(spawn(despawn_join(Cmd.tx_despawn_with(~S.Schema,~S.Store,~Unit,~Unit,~S.clear,T.begin(~S.World(),~Unit,world),handle(namespace,2))),S.churn_bundle()),handle(namespace,1),Some{S.recipe_payload(27)}))
def churn(world: S.World()) -> S.World():
  churn_namespace(W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def advanced_replace_namespace(named: S.World() & U32) -> S.World():
  (world,+namespace) = named
  commit(S.queue_stock(S.queue_recipe(T.begin(~S.World(),~Unit,world),handle(namespace,3),Some{S.recipe_payload(88)}),handle(namespace,3),Some{S.stock_payload(89)}))
def advanced_replace(world: S.World()) -> S.World():
  advanced_replace_namespace(W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def barrier(world: S.World()) -> S.World():
  W.barrier(~S.Schema,~S.Store,~Unit,~Unit,world)
