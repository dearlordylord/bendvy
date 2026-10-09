import Base
import ../library/public-relation-readers/keyed-candidate/application.bend as A
import ../library/public-relation-readers/keyed-candidate/closed-access.bend as Access
import ../library/public-relation-readers/keyed-candidate/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/relation-commands.bend as RC

# This closed-schema gameplay has only Parent; request OtherParent instead.
def undeclared(~H: Type,~get: H -> H & List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>,grant: Access.ReadGrant<H,A.ReadersAlpha,Access.Parent<A.ReadersAlpha>,RC.Notice<A.ReadersAlpha,U32>,get>,owner: H) -> H & List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>:
  Access.all(~H,~A.ReadersAlpha,~Access.OtherParent<A.ReadersAlpha>,~RC.Notice<A.ReadersAlpha,U32>,~get,grant,owner)
