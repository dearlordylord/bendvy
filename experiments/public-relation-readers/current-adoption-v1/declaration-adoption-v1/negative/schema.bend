import Base
import ../library/public-relation-readers/keyed-candidate/application.bend as A
import ../library/public-relation-readers/keyed-candidate/closed-access.bend as Access
import ../library/public-relation-readers/keyed-candidate/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/relation-commands.bend as RC

# Alpha's actual closed grant cannot serve the Beta gameplay contract.
def cross_schema(~H: Type,~alpha: H -> H & List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>,~beta: H -> H & List<&2,Read.KeyReading<A.ReadersBeta,RC.Notice<A.ReadersBeta,U32>>>,grant: Access.ReadGrant<H,A.ReadersAlpha,Access.Parent<A.ReadersAlpha>,RC.Notice<A.ReadersAlpha,U32>,alpha>,owner: H) -> H & List<&2,Read.KeyReading<A.ReadersBeta,RC.Notice<A.ReadersBeta,U32>>>:
  Access.gameplay(~H,~A.ReadersBeta,~RC.Notice<A.ReadersBeta,U32>,~beta,grant,owner)
