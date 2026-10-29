import Base
import ./execution-event-family.bend as Family
import ./world-namespace.bend as Identity

# Uses the same process/realm identity allocator as World creation.
def create(~S:Data,~P:Type,~key:String) -> IO(Family.Creation<S,P,key>):
  IO.bind(U32,Family.Creation<S,P,key>,Identity.fresh(),identity=>IO.pure(Family.Creation<S,P,key>,Family.allocated(~S,~P,~key,identity)))
