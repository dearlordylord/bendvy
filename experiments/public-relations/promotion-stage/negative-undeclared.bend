import Base
import ../../../src/ecs/relation-providers.bend as P
import ../../../src/ecs/relation-commands.bend as A
# Only inverse read is declared; no relation/clear capability is in this header.
def bad(~S: Data,-H: Type,caps: P.ReadOnly<H,S>,args: P.Targets<S>,owner: H) -> H & A.QueueStatus:
  P.relate_live(H,S,relation_write,owner,args)
