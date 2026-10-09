import Base
import ../library/public-relation-readers/keyed-candidate/application.bend as A
import ../library/public-relation-readers/keyed-candidate/closed-access.bend as Access
import ../library/public-relation-readers/keyed-candidate/readings.bend as Read
import ../../../../src/ecs/relation-commands.bend as RC

# A read grant does not provision publication authority to the abstract owner.
def write_read(~H: Type,~get: H -> H & List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>,~put: H -> RC.Notice<A.ReadersAlpha,U32> -> H,grant: Access.ReadGrant<H,A.ReadersAlpha,Access.Parent<A.ReadersAlpha>,RC.Notice<A.ReadersAlpha,U32>,get>,owner: H) -> H:
  Access.write(~H,~A.ReadersAlpha,~Access.Parent<A.ReadersAlpha>,~RC.Notice<A.ReadersAlpha,U32>,~put,grant,owner,RC.Original{999})
