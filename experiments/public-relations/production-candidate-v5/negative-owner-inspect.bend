import Base
import relation-providers.bend as P
import relation-commands.bend as A
import owned-world.bend as O
import ../../../src/ecs/world.bend as W
def bad(-H: Type,caps: P.ReadOnly<H,O.Workshop>,owner: H) -> H & U32:
  W.namespace(~O.Workshop,~A.Store<O.Workshop,O.Components<O.Workshop>>,~U32,~A.Notice<O.Workshop,U32>,owner)
