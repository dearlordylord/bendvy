import Base
import ../alpha/application.bend as Alpha
import ../beta/application.bend as Beta
import ../alpha/state.bend as F
import ../alpha/bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule-access.bend as Access
def subject(app:Alpha.Scheduled()) -> Alpha.Scheduled() & Maybe<&2,Access.Index>:
  Access.index(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),app)
def main() -> U32:
  0
