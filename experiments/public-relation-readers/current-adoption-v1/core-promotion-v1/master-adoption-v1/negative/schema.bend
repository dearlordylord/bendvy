import Base
import ../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../src/ecs/relation-commands.bend as RC
import ../../../../../../src/ecs/internal/relation-failures/readings.bend as Read
import ../provider.bend as Provider
import ../library/public-relation-readers/keyed-candidate/application.bend as A

def bad(~H:Type,~cap:Cap.ValueRead<H,List<&2,Read.KeyReading<A.ReadersAlpha,RC.Notice<A.ReadersAlpha,U32>>>>,owner:H) -> H & List<&2,Read.KeyReading<A.ReadersBeta,RC.Notice<A.ReadersBeta,U32>>>:
  Provider.gameplay(~H,~A.ReadersBeta,~RC.Notice<A.ReadersBeta,U32>,~cap,owner)
