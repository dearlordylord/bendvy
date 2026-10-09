import Base
import provider.bend as P
import context.bend as Ctx

# An opaque callback owner cannot be used as the concrete engine transaction.
def gameplay(~H: Type,ctx: H) -> H:
  Ctx.Frame{ctx,None{}}
