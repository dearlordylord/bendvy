import Base
import ../normal-values.bend as Game
import ../canonical-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def readonly(-H:Type,cap:Cap.ValueRead<H,Bool>) -> Cap.ValueRead<H,Bool>:
  cap
def keep(owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>) -> Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()> & Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>:
  (owner,owner)
def path() -> Schema.Path:
  Schema.Right{}
