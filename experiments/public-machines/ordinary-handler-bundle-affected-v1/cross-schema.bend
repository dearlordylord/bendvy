import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-machines/ordinary-handler-bundle-adapter-v1/adapter.bend as Bridge
import ./consumer.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/bridge.bend as Clock
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/systems.bend as Systems
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/world.bend as Lens
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
def wrong_world(bundle:B.Bundle<T.SchemaB,T.MachineKey,T.State,U32,T.Store<T.SchemaB>,T.Resources<T.SchemaB>,Unit,Systems.runner(~T.SchemaB)>,world:W.World<T.SchemaA,T.Store<T.SchemaA>,T.Resources<T.SchemaA>,Unit>) -> Bridge.MarkerResult<T.SchemaB,T.MachineKey,T.State,U32,T.Store<T.SchemaB>,T.Resources<T.SchemaB>,Unit,Systems.runner(~T.SchemaB)>:
  Bridge.run(~T.SchemaB,~T.MachineKey,~T.State,~U32,~T.Store<T.SchemaB>,~T.Resources<T.SchemaB>,~Unit,~Systems.runner(~T.SchemaB),~Lens.take(~T.SchemaB),~Lens.put(~T.SchemaB),~Clock.published(~T.SchemaB),~T.same,~U32.is_eq,~C.has(~T.SchemaB),~Clock.tick(~T.SchemaB),Ordinary.declare(~T.SchemaB,"handler-bundle-global-marker"),bundle,world)
