import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/readings.bend as Read
import ../provider.bend as Provider
import ../library/public-relation-readers/keyed-candidate/application.bend as A

# Only the actual closed ValueRead was provided. There is no second read slot.
def bad(~H:Type,~S:Data,~E:Data,~cap:Cap.ValueRead<H,List<&2,Read.KeyReading<S,E>>>,owner:H) -> H & List<&2,Read.KeyReading<S,E>>:
  Provider.gameplay(~H,~S,~E,~Cap.second(~Cap.ValueRead<H,List<&2,Read.KeyReading<S,E>>>,~Cap.ValueRead<H,List<&2,Read.KeyReading<S,E>>>,cap),owner)
