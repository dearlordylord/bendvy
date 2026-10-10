import Base
import ./event-runtime.bend as Ev
import ./relation-commands.bend as A

# The actual event domain owner remains affine. Inspection has its own cursor
# and never invokes an event reader or an operational with_world step.
type Frame<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Frame{runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>,cursor:U32}
