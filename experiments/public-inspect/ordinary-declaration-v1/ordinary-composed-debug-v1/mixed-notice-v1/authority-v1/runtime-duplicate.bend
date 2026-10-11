import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Notice
def duplicate(runtime:Events.Runtime()) -> Events.Runtime() & Events.Runtime():(runtime,runtime)
def main() -> Unit:Unit{}
