import Base
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine.bend as M
import provider.bend as P
import context.bend as Ctx

# Readonly gameplay has no next-machine operation. Concrete provider bypass
# cannot consume the abstract gameplay owner.
def gameplay(~H: Type,ctx: H) -> H:
  Ctx.flow_next(~P.SchemaA,ctx,M.Set{P.Play{},False{}})
