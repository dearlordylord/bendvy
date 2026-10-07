import Base
import ../../src/ecs/query-contract.bend as QC
import ../../src/ecs/world.bend as W
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/declarations.bend as D
import ../../examples/query-composition/gameplay.bend as G

type Other is Data:
  Other{}
def bad(world: S.World(),handle: W.Handle<Other>) -> QC.Executed<S.World(),G.Error,String>:
  QC.get(~S.Schema,~S.Store,~Unit,~Unit,~D.EmptyOps,~D.empty_plan(),~Unit,~G.Error,~String,~D.empty_body,Unit{},world,handle,0)
