import Base
import ../inspection-provision-public.bend as Inspection
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/event-setup.bend as Events
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/other/event-setup.bend as Other
def attempted(runtime:Other.Runtime()) -> Other.Runtime() & Maybe<&2,List<&2,F.FirstEvent>>:Cap.value_read_field(~Events.Runtime(),~Maybe<&2,List<&2,F.FirstEvent>>,Inspection.first(Events.provision()))(runtime)
def main() -> Unit:Unit{}
