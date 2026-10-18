import Base
import types.bend as T
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/relation-commands.bend as Notice

type Publication is Data:
  Ping{code:U32}
  Removed{handle:W.Handle<T.MotionSchema>}
  Despawned{handle:W.Handle<T.MotionSchema>}
def event_type() -> Data:Notice.Notice<T.MotionSchema,Publication>
