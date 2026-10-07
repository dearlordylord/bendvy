import Base
import relation-providers.bend as P
import relation-commands.bend as A
def bad(~S: Data,-H: Type,caps: P.ReadOnly<H,S>,args: P.Targets<S>,owner: H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)
