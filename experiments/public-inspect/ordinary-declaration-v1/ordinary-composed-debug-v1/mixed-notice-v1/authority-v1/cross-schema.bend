import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Notice
type Other is Data:Other{}
def ForeignState() -> Type:Mixed.State<Other,Events.Events(),Events.Metadata(),Array<U32>>
def ForeignRuntime() -> Type:Route.Runtime<Other,F.Store(),F.Resources(),Notice.Notice<Other,Events.Events()>,ForeignState()>
def misuse(runtime:ForeignRuntime()) -> Events.Runtime():
  Mixed.frame(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.frame(),~Events.retain(),runtime)
def main() -> Unit:Unit{}
