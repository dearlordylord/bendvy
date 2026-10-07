import Base
import ../../../src/ecs/relation-providers.bend as P
import ../../../src/ecs/relation-commands.bend as A
def bad(~S: Data,-H: Type,caps: P.ReadOnly<H,S>,args: P.Targets<S>,owner: H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)
