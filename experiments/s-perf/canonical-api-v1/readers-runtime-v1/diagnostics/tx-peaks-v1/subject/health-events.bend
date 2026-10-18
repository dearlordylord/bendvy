import Base
import types.bend as T
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/relation-commands.bend as Notice

type Publication is Data:
  Ping{code:U32}
  Removed{handle:W.Handle<T.HealthSchema>}
  Despawned{handle:W.Handle<T.HealthSchema>}
def event_type() -> Data:Notice.Notice<T.HealthSchema,Publication>
