import Base
import ../library/public-relation-readers/keyed-candidate/application.bend as A
import ../library/public-relation-readers/keyed-candidate/closed-access.bend as Access
import ../library/public-relation-readers/keyed-candidate/readings.bend as Read
import ../../../../src/ecs/relation-commands.bend as RC

def duplicate(~H: Type,~get: H -> H & List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>,_: Access.ReadGrant<H,A.ReadersAlpha,Access.Parent<A.ReadersAlpha>,RC.Notice<A.ReadersAlpha,U32>,get>,owner: H) -> H & H:
  (owner,owner)
