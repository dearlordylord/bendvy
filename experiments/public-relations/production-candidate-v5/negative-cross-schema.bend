import Base
import relation-providers.bend as P
import relation-commands.bend as A
import owned-world.bend as O
import ../../../src/ecs/world.bend as W
def bad(-H: Type,caps: P.Writable<H,O.Workshop>,foreign: W.Handle<O.Other>,target: W.Handle<O.Workshop>,owner: H) -> H & A.QueueStatus:
  P.relate_live(H,O.Workshop,caps,owner,P.Targets{foreign,target})
