import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import ../public-v1/reader-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def misuse(owner:B.FirstOwner(),runtime:Events.Runtime()) -> Reader.RunResult<F.S,F.Store,F.Resources,F.Events(),F.SecondEvent,Events.State(),Bool,B.ReadError<F.SecondEvent>,Ev.Reading<F.SecondEvent>,Events.take_second,Events.put_second,B.second_runner>:
  Reader.run(~F.S,~F.Store,~F.Resources,~F.Events(),~F.SecondEvent,~Events.State(),~Bool,~B.ReadError<F.SecondEvent>,~Ev.Reading<F.SecondEvent>,~Events.take_second,~Events.put_second,~B.second_runner,~Events.synchronize,owner,runtime,False{})
def main() -> Unit:Unit{}
