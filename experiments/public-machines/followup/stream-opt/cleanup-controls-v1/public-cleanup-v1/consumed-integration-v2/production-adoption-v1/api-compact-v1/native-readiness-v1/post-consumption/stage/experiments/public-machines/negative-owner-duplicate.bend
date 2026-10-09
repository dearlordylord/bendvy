import Base
import provider.bend as P
import context.bend as Ctx

def duplicate(owner: Ctx.Frame<P.SchemaA>) -> Ctx.Frame<P.SchemaA> & Ctx.Frame<P.SchemaA>:
  (owner,owner)
